-- ============================================================
-- SwiftBasket Quick Commerce | SQL Portfolio Project
-- FILE: 03_analysis.sql
-- PURPOSE: 5 Business Problems solved with SQL
-- SQL Server 2022  |  Uses clean schema only
-- ============================================================

USE SwiftBasket;
GO

-- ============================================================
-- PROBLEM 1: CUSTOMER COHORT & RETENTION ANALYSIS
-- Business Question:
--   Which acquisition channel retains customers the longest?
--   What is the repeat purchase rate by channel and city?
-- Concepts: CTEs, ROW_NUMBER(), DATEDIFF, conditional aggregation
-- ============================================================

-- Step 1a: Build customer order history with cohort month
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.city,
        c.acquisition_channel,
        c.signup_date,

        -- Cohort = month of first order
        DATEFROMPARTS(
            YEAR(MIN(o.order_ts)  OVER (PARTITION BY o.customer_id)),
            MONTH(MIN(o.order_ts) OVER (PARTITION BY o.customer_id)),
            1
        )                                               AS cohort_month,

        -- Number of months since cohort start
        DATEDIFF(
            MONTH,
            DATEFROMPARTS(
                YEAR(MIN(o.order_ts)  OVER (PARTITION BY o.customer_id)),
                MONTH(MIN(o.order_ts) OVER (PARTITION BY o.customer_id)),
                1
            ),
            DATEFROMPARTS(YEAR(o.order_ts), MONTH(o.order_ts), 1)
        )                                               AS months_since_first,

        CAST(o.order_ts AS DATE)                        AS order_date,
        o.effective_revenue
    FROM clean.fact_orders o
    JOIN clean.dim_customer c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),

-- Step 1b: Count distinct active customers per cohort × month_offset
cohort_size AS (
    SELECT
        cohort_month,
        acquisition_channel,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM customer_orders
    WHERE months_since_first = 0
    GROUP BY cohort_month, acquisition_channel
),

retention_data AS (
    SELECT
        co.cohort_month,
        co.acquisition_channel,
        co.months_since_first,
        COUNT(DISTINCT co.customer_id) AS active_customers
    FROM customer_orders co
    GROUP BY co.cohort_month, co.acquisition_channel, co.months_since_first
)

-- Final: Retention rate by channel × month offset
SELECT
    r.acquisition_channel,
    r.cohort_month,
    r.months_since_first,
    r.active_customers,
    cs.cohort_customers,
    CAST(
        100.0 * r.active_customers / NULLIF(cs.cohort_customers, 0)
    AS DECIMAL(5,1))                            AS retention_pct,

    -- Running avg retention for channel
    CAST(
        AVG(
            100.0 * r.active_customers / NULLIF(cs.cohort_customers, 0)
            ) OVER (
            PARTITION BY r.acquisition_channel
            ORDER BY r.months_since_first
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) 
       
      AS DECIMAL(5,1))        AS rolling_3m_avg_retention
FROM retention_data r
JOIN cohort_size cs
    ON  r.cohort_month        = cs.cohort_month
    AND r.acquisition_channel = cs.acquisition_channel
ORDER BY r.acquisition_channel, r.cohort_month, r.months_since_first;
GO


-- ============================================================
-- PROBLEM 2: DELIVERY SLA BREACH & RIDER PERFORMANCE
-- Business Question:
--   Which stores and riders have the worst late delivery rates
--   on rainy days? Does distance explain it?
-- Concepts: CASE WHEN, HAVING, window RANK, conditional aggregation
-- ============================================================

WITH delivery_summary AS (
    SELECT
        d.store_id,
        s.locality                              AS store_locality,
        d.rider_id,
        d.is_rainy,

        COUNT(*)                                AS total_deliveries,

        -- Late % overall
        CAST(
            100.0 * SUM(CAST(d.is_late AS INT)) / COUNT(*)
        AS DECIMAL(5,1))                        AS late_pct_overall,

        -- Late % on rainy days only
        CAST(
            100.0 *
            SUM(CASE WHEN d.is_rainy = 1 AND d.is_late = 1 THEN 1 ELSE 0 END) /
            NULLIF(SUM(CASE WHEN d.is_rainy = 1 THEN 1 ELSE 0 END), 0)
        AS DECIMAL(5,1))                        AS late_pct_rainy,

        AVG(d.actual_mins)                      AS avg_actual_mins,
        AVG(d.distance_km)                      AS avg_distance_km,
        AVG(d.pick_pack_mins)                   AS avg_pick_pack_mins

    FROM clean.fact_delivery d
    JOIN clean.dim_store s ON d.store_id = s.store_id
    GROUP BY d.store_id, s.locality, d.rider_id, d.is_rainy
    HAVING COUNT(*) >= 10                       -- only riders with meaningful volume
),

-- Rank riders within each store by rainy-day late %
ranked_riders AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY store_id
               ORDER BY late_pct_rainy DESC
           ) AS rank_worst_rainy
    FROM delivery_summary
    WHERE is_rainy = 1
)

SELECT
    store_id,
    store_locality,
    rider_id,
    total_deliveries,
    late_pct_rainy,
    late_pct_overall,
    avg_actual_mins,
    avg_distance_km,
    avg_pick_pack_mins,
    rank_worst_rainy,

    -- Flag if distance is likely explaining the lateness
    CASE
        WHEN avg_distance_km > 3.0 AND late_pct_rainy > 40 THEN 'Distance + Rain'
        WHEN avg_distance_km <= 3.0 AND late_pct_rainy > 40 THEN 'Ops Issue (not distance)'
        ELSE 'Within SLA'
    END                                         AS root_cause_flag

FROM ranked_riders
WHERE rank_worst_rainy <= 5                     -- top 5 worst riders per store
ORDER BY store_id, rank_worst_rainy;
GO


-- ============================================================
-- PROBLEM 3: PROMO EFFECTIVENESS & MARGIN IMPACT
-- Business Question:
--   Which promotions drove real volume uplift vs just margin giveaway?
--   Which product–store combos had the best promo ROI?
-- Concepts: LEFT JOIN for orphan detection, CTEs, ROI calculation
-- ============================================================

-- Step 3a: Identify promo vs non-promo baseline per product
WITH product_baselines AS (
    SELECT
        o.product_id,
        p.product_name,
        p.category,

        -- Non-promo baseline: avg daily units sold
        AVG(CASE WHEN o.is_promo = 0 THEN CAST(o.units AS FLOAT) END)
                                                AS baseline_daily_units,

        -- Promo average
        AVG(CASE WHEN o.is_promo = 1 THEN CAST(o.units AS FLOAT) END)
                                                AS promo_daily_units,

        -- Revenue metrics
        AVG(CASE WHEN o.is_promo = 0 THEN o.effective_revenue END)
                                                AS baseline_avg_revenue,
        AVG(CASE WHEN o.is_promo = 1 THEN o.effective_revenue END)
                                                AS promo_avg_revenue,

        -- Cost metrics
        AVG(o.cogs_per_unit)                    AS avg_cogs,
        AVG(CASE WHEN o.is_promo = 1 THEN o.discount_pct END)
                                                AS avg_discount_pct

    FROM clean.fact_orders o
    JOIN clean.dim_product p ON o.product_id = p.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.product_id, p.product_name, p.category
),

-- Step 3b: Promo ROI per product–store
promo_roi AS (
    SELECT
        o.store_id,
        s.locality                              AS store_locality,
        o.product_id,
        pb.product_name,
        pb.category,
        COUNT(DISTINCT o.order_id)              AS promo_orders,
        SUM(o.units)                            AS total_units_sold,
        SUM(o.discount_amount)                  AS total_discount_given,
        SUM(o.effective_revenue)                AS total_revenue,
        SUM(o.units * o.cogs_per_unit)          AS total_cogs,

        -- Gross margin with promo
        SUM(o.effective_revenue) - SUM(o.units * o.cogs_per_unit)
                                                AS gross_margin,

        -- Volume uplift % vs non-promo baseline
        CAST(
            100.0 *
            (AVG(CAST(o.units AS FLOAT)) - pb.baseline_daily_units) /
            NULLIF(pb.baseline_daily_units, 0)
        AS DECIMAL(6,1))                        AS volume_uplift_pct,

        -- ROI = gross margin / discount given
        CAST(
            (SUM(o.effective_revenue) - SUM(o.units * o.cogs_per_unit)) /
            NULLIF(SUM(o.discount_amount), 0)
        AS DECIMAL(8,2))                        AS promo_roi

    FROM clean.fact_orders o
    JOIN clean.dim_store   s  ON o.store_id  = s.store_id
    JOIN product_baselines pb ON o.product_id = pb.product_id

    -- Only confirmed promo orders that have a matching promo record
    JOIN clean.fact_promotions fp
        ON  CAST(o.order_ts AS DATE) = fp.promo_date
        AND o.store_id               = fp.store_id
        AND o.product_id             = fp.product_id
        AND fp.is_promo              = 1

    WHERE o.is_promo = 1
      AND o.order_status = 'delivered'
    GROUP BY o.store_id, s.locality, o.product_id,
             pb.product_name, pb.category, pb.baseline_daily_units
)

SELECT
    store_id,
    store_locality,
    product_id,
    product_name,
    category,
    promo_orders,
    total_units_sold,
    total_discount_given,
    total_revenue,
    gross_margin,
    volume_uplift_pct,
    promo_roi,

    -- Classify each promo
    CASE
        WHEN volume_uplift_pct > 20 AND promo_roi > 2  THEN 'Star Promo'
        WHEN volume_uplift_pct > 20 AND promo_roi <= 2 THEN 'Volume Only (margin risk)'
        WHEN volume_uplift_pct <= 20 AND promo_roi > 2 THEN 'Efficient (low volume boost)'
        ELSE 'Poor ROI'
    END                                         AS promo_classification,

    -- Rank by ROI within each category
    RANK() OVER (
        PARTITION BY category
        ORDER BY promo_roi DESC
    )                                           AS rank_in_category

FROM promo_roi
ORDER BY promo_roi DESC;
GO


-- ============================================================
-- PROBLEM 4: INVENTORY STOCKOUT RISK & REORDER ALERTS
-- Business Question:
--   Which store–product combos are below reorder point today?
--   How many days until stockout based on avg daily sales velocity?
-- Concepts: Window functions, DATEDIFF velocity calc, risk tiers
-- ============================================================

-- Step 4a: Calculate average daily sales velocity (last 30 days)
WITH sales_velocity AS (
    SELECT
        o.store_id,
        o.product_id,
        SUM(o.units) * 1.0 /
            NULLIF(DATEDIFF(DAY,
                MIN(CAST(o.order_ts AS DATE)),
                MAX(CAST(o.order_ts AS DATE))
            ) + 1, 0)                           AS avg_daily_units_sold
    FROM clean.fact_orders o
    WHERE o.order_status = 'delivered'
      AND o.order_ts >= DATEADD(DAY, -30, (SELECT MAX(order_ts) FROM clean.fact_orders))
    GROUP BY o.store_id, o.product_id
),

-- Step 4b: Latest inventory snapshot per store-product
latest_inventory AS (
    SELECT
        i.inventory_date,
        i.store_id,
        i.product_id,
        i.stock_on_hand,
        ROW_NUMBER() OVER (
            PARTITION BY i.store_id, i.product_id
            ORDER BY i.inventory_date DESC
        ) AS rn
    FROM clean.fact_inventory i
),

current_stock AS (
    SELECT inventory_date, store_id, product_id, stock_on_hand
    FROM latest_inventory
    WHERE rn = 1
),

-- Step 4c: Join to product reorder points
stockout_analysis AS (
    SELECT
        cs.store_id,
        st.locality                             AS store_locality,
        st.tier_label,
        cs.product_id,
        p.product_name,
        p.category,
        p.is_perishable,
        p.reorder_point_units,                  -- already defaulted via clean.dim_product
        cs.inventory_date                       AS stock_as_of,
        cs.stock_on_hand,
        sv.avg_daily_units_sold,

        -- Days until stockout
        CASE
            WHEN sv.avg_daily_units_sold > 0
                THEN CAST(cs.stock_on_hand / sv.avg_daily_units_sold AS INT)
            ELSE 999
        END                                     AS days_until_stockout,

        -- Units below reorder threshold
        p.reorder_point_units - cs.stock_on_hand AS units_below_reorder

    FROM current_stock cs
    JOIN clean.dim_store   st ON cs.store_id  = st.store_id
    JOIN clean.dim_product p  ON cs.product_id = p.product_id
    LEFT JOIN sales_velocity sv
        ON  cs.store_id  = sv.store_id
        AND cs.product_id = sv.product_id
)

SELECT
    store_id,
    store_locality,
    tier_label,
    product_id,
    product_name,
    category,
    is_perishable,
    reorder_point_units,
    stock_on_hand,
    avg_daily_units_sold,
    days_until_stockout,
    units_below_reorder,

    -- Risk tier
    CASE
        WHEN stock_on_hand = 0                          THEN 'STOCKOUT'
        WHEN days_until_stockout <= 2                   THEN 'CRITICAL (≤2 days)'
        WHEN days_until_stockout <= 5                   THEN 'HIGH RISK (3-5 days)'
        WHEN stock_on_hand < reorder_point_units        THEN 'REORDER NEEDED'
        ELSE 'OK'
    END                                                 AS risk_tier,

    -- Recommended reorder quantity: 7-day cover + reorder point buffer
    CASE
        WHEN avg_daily_units_sold > 0
            THEN CAST(
                    (avg_daily_units_sold * 7) + reorder_point_units - stock_on_hand
                AS INT)
        ELSE 0
    END                                                 AS recommended_order_qty,

    -- Rank most critical items per store
    RANK() OVER (
        PARTITION BY store_id
        ORDER BY days_until_stockout ASC
    )                                                   AS urgency_rank

FROM stockout_analysis
WHERE stock_on_hand < reorder_point_units       -- only items needing attention
   OR days_until_stockout <= 5
ORDER BY days_until_stockout ASC, store_id;
GO


-- ============================================================
-- PROBLEM 5: FESTIVAL DEMAND SPIKE DETECTION
-- Business Question:
--   Which categories spike the most in the 3-day window before
--   a festival? 
-- Concepts: Date range joins, RATIO_TO_REPORT (% of total),
--          , string functions
-- ============================================================

-- Step 5a: Tag every order date with its festival context

WITH order_festival AS (
    SELECT
        o.order_id,
        o.order_line_id,
        CAST(o.order_ts AS DATE)                AS order_date,
        o.store_id,
        o.product_id,
        p.category,
        o.units,
        o.effective_revenue,
        fc.festival_name,
        fc.days_from_festival,
        CASE
            WHEN fc.days_from_festival BETWEEN -3 AND 0 THEN 'Pre-Festival'
            WHEN fc.days_from_festival BETWEEN 1  AND 3 THEN 'Post-Festival'
            ELSE 'Normal'
        END                                     AS period_type
    FROM clean.fact_orders o
    JOIN clean.dim_product p ON o.product_id = p.product_id
    -- Range join: match order date to festival window dates
    LEFT JOIN clean.festival_calendar fc
        ON  CAST(o.order_ts AS DATE) = fc.festival_date
    WHERE o.order_status = 'delivered'
),

-- Step 5b: Average daily sales by period type × category × festival
period_sales AS (
    SELECT
        category,
        festival_name,
        period_type,
        COUNT(DISTINCT order_date)              AS distinct_days,
        SUM(units)                              AS total_units,
        SUM(units) * 1.0 /
            NULLIF(COUNT(DISTINCT order_date), 0)
                                                AS avg_daily_units,
        SUM(effective_revenue)                  AS total_revenue
    FROM order_festival
    GROUP BY category, festival_name, period_type
),

-- Step 5c: Spike calculation vs normal baseline
normal_baseline AS (
    SELECT category, CAST(avg_daily_units AS DECIMAL(10,2)) AS normal_daily_units
    FROM period_sales
    WHERE period_type = 'Normal'
      AND festival_name IS NULL
),

festival_spikes AS (
    SELECT
        ps.category,
        ps.festival_name,
        ps.period_type,
        CAST(ps.avg_daily_units AS DECIMAL(10,2))                    AS festival_period_daily,
        nb.normal_daily_units,
        CAST(
            100.0 * (ps.avg_daily_units - nb.normal_daily_units) /
            NULLIF(nb.normal_daily_units, 0)
        AS DECIMAL(6,1))                        AS spike_pct,

        -- Share of festival period revenue
        CAST(
            100.0 * ps.total_revenue /
            SUM(ps.total_revenue) OVER (PARTITION BY ps.festival_name, ps.period_type)
        AS DECIMAL(5,1))                        AS revenue_share_pct

    FROM period_sales ps
    JOIN normal_baseline nb ON ps.category = nb.category
    WHERE ps.period_type = 'Pre-Festival'
)


-- Final Output 5A: Festival spike leaderboard by category
SELECT
    category,
    festival_name,
    festival_period_daily,
    normal_daily_units,
    spike_pct,
    revenue_share_pct,
    RANK() OVER (
        PARTITION BY festival_name
        ORDER BY spike_pct DESC
    )                                           AS spike_rank
FROM festival_spikes
ORDER BY festival_name, spike_pct DESC;

PRINT 'All 5 analyses complete.';
GO


