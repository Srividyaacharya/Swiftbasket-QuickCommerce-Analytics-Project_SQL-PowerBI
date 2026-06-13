-- ============================================================
-- SwiftBasket Quick Commerce | SQL Portfolio Project
-- FILE: 02_data_cleaning.sql
-- PURPOSE: Audit raw data → document issues → insert clean data
-- SQL Server 2022
-- Run AFTER 01_create_schema.sql and after importing raw data
-- ============================================================

USE SwiftBasket;
GO

-- ============================================================
-- SECTION A: DATA QUALITY AUDIT (run these first, read output)
-- ============================================================

PRINT '========== DATA QUALITY AUDIT REPORT ==========';

-- ── A1. dim_customer ─────────────────────────────────────────
PRINT '--- dim_customer ---'

-- Check: duplicate customer_ids
SELECT 'Duplicate customer_ids' AS issue, COUNT(*) AS cnt
FROM (
    SELECT customer_id, COUNT(*) AS n
    FROM raw.dim_customer
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) x;

-- Check: NULLs in city
SELECT 'NULL city' AS issue, COUNT(*) AS cnt
FROM raw.dim_customer
WHERE city IS NULL OR LTRIM(RTRIM(city)) = '';

-- Check: mixed case acquisition_channel
SELECT 'acquisition_channel distinct values' AS issue, acquisition_channel, COUNT(*) AS cnt
FROM raw.dim_customer
GROUP BY acquisition_channel
ORDER BY acquisition_channel;

-- ── A2. fact_delivery ────────────────────────────────────────
PRINT '--- fact_delivery ---';

-- Check: negative or NULL actual_mins
SELECT 'Negative actual_mins' AS issue, COUNT(*) AS cnt
FROM raw.fact_delivery WHERE actual_mins < 0;

SELECT 'NULL actual_mins' AS issue, COUNT(*) AS cnt
FROM raw.fact_delivery WHERE actual_mins IS NULL;

-- Check: pickup_ts before order_ts (timestamp logic error)
SELECT 'pickup_ts before order_ts' AS issue, COUNT(*) AS cnt
FROM raw.fact_delivery
WHERE pickup_ts < order_ts;

-- Check: is_rainy mixed formats
SELECT 'is_rainy distinct values' AS issue, is_rainy, COUNT(*) AS cnt
FROM raw.fact_delivery
GROUP BY is_rainy;

-- ── A3. fact_orders ──────────────────────────────────────────
PRINT '--- fact_orders ---';

-- Check: duplicate order_line_ids
SELECT 'Duplicate order_line_ids' AS issue, COUNT(*) AS cnt
FROM (
    SELECT order_line_id, COUNT(*) AS n
    FROM raw.fact_orders
    GROUP BY order_line_id
    HAVING COUNT(*) > 1
) x;

-- Check: discount_pct mixed format (string % vs numeric)
SELECT 'discount_pct string format' AS issue, COUNT(*) AS cnt
FROM raw.fact_orders
WHERE discount_pct LIKE '%[%]%';    -- contains % sign

-- Check: is_promo=1 orders with no matching promo record
SELECT 'Orphan promo orders (no fact_promotions match)' AS issue, COUNT(*) AS cnt
FROM raw.fact_orders fo
LEFT JOIN raw.fact_promotions fp
    ON  CAST(fo.order_ts AS DATE) = fp.promo_date
    AND fo.store_id  = fp.store_id
    AND fo.product_id = fp.product_id
WHERE fo.is_promo = 1
  AND fp.promo_date IS NULL;

-- ── A4. fact_inventory ───────────────────────────────────────
PRINT '--- fact_inventory ---';

SELECT 'Negative stock_on_hand' AS issue, COUNT(*) AS cnt
FROM raw.fact_inventory WHERE stock_on_hand < 0;

SELECT 'Duplicate inventory rows (same store+product+date)' AS issue, COUNT(*) AS cnt
FROM (
    SELECT inventory_date, store_id, product_id, COUNT(*) n
    FROM raw.fact_inventory
    GROUP BY inventory_date, store_id, product_id
    HAVING COUNT(*) > 1
) x;

-- ── A5. dim_product ──────────────────────────────────────────
PRINT '--- dim_product ---';
SELECT 'NULL reorder_point_units' AS issue, COUNT(*) AS cnt
FROM raw.dim_product WHERE reorder_point_units IS NULL;

-- ── A6. festival_calendar ────────────────────────────────────
PRINT '--- festival_calendar ---';

-- Mixed date formats (DD-MM-YYYY vs YYYY-MM-DD)

WITH Classified AS
(
SELECT
    CASE
        WHEN TRY_CONVERT(date, date, 105) IS NOT NULL
            THEN 'DD-MM-YYYY'

        WHEN TRY_CONVERT(date, date, 23) IS NOT NULL
            THEN 'YYYY-MM-DD'
        ELSE 'INVALID'
    END AS date_format
FROM raw.festival_calendar
)
SELECT date_format,COUNT(*) AS cnt  FROM Classified
GROUP BY date_format;

-- Trailing spaces in festival_name
SELECT 'Trailing spaces in festival_name' AS issue, COUNT(*) AS cnt
FROM raw.festival_calendar
WHERE festival_name <> LTRIM(RTRIM(festival_name));


-- ============================================================
-- SECTION B: CLEAN DATA → INSERT INTO clean SCHEMA
-- ============================================================

PRINT '========== LOADING CLEAN TABLES ==========';

-- ── B1. clean.dim_customer ───────────────────────────────────
-- Rules:
--   1. Remove duplicates → keep earliest signup_date per customer_id
--   2. Standardise acquisition_channel to UPPER
--   3. Fill NULL city from store locality match via fact_orders
TRUNCATE TABLE clean.dim_customer;

WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY TRY_CAST(signup_date AS DATE) ASC   -- keep earliest
           ) AS rn
    FROM raw.dim_customer
)
INSERT INTO clean.dim_customer
SELECT
    r.customer_id,
    COALESCE(
        NULLIF(LTRIM(RTRIM(r.city)), ''),
        s.city                      -- fallback: city of the store they ordered from
    )                                   AS city,
    LTRIM(RTRIM(r.locality))            AS locality,
    r.age_group,
    UPPER(LTRIM(RTRIM(r.acquisition_channel))) AS acquisition_channel,
    TRY_CAST(r.signup_date AS DATE)     AS signup_date,
    CAST(r.is_app_user AS BIT)          AS is_app_user
FROM ranked r
-- For null-city fill: join to first order → get store → get city
OUTER APPLY (
    SELECT TOP 1 st.city
    FROM raw.fact_orders fo
    JOIN raw.dim_store st ON fo.store_id = st.store_id
    WHERE fo.customer_id = r.customer_id
    ORDER BY fo.order_ts
) s
WHERE r.rn = 1;

PRINT 'clean.dim_customer loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ── B2. clean.dim_product ────────────────────────────────────
-- Rules:
--   1. Fill NULL reorder_point_units with category median
TRUNCATE TABLE clean.dim_product;

WITH category_median AS (
    -- Calculate median reorder point per category for filling NULLs
    SELECT category,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY reorder_point_units)
               OVER (PARTITION BY category) AS median_reorder
    FROM raw.dim_product
    WHERE reorder_point_units IS NOT NULL
)
INSERT INTO clean.dim_product
SELECT
    p.product_id,
    LTRIM(RTRIM(p.product_name))                AS product_name,
    LTRIM(RTRIM(p.category))                    AS category,
    CAST(p.base_price    AS DECIMAL(10,2))      AS base_price,
    LTRIM(RTRIM(p.sub_category))                AS sub_category,
    CAST(p.is_perishable AS BIT)                AS is_perishable,
    CAST(
        COALESCE(
            p.reorder_point_units,
            cm.median_reorder,
            10                          -- absolute fallback
        ) AS INT
    )                                           AS reorder_point_units
FROM raw.dim_product p
LEFT JOIN (
    SELECT DISTINCT category, MAX(median_reorder) AS median_reorder
    FROM category_median
    GROUP BY category
) cm ON p.category = cm.category;

PRINT 'clean.dim_product loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ── B3. clean.dim_store ──────────────────────────────────────
-- Already clean — straight load
TRUNCATE TABLE clean.dim_store;
INSERT INTO clean.dim_store
SELECT store_id, store_name, city, locality, zone, tier, tier_label,
       latitude, longitude, store_open_date
FROM raw.dim_store;
PRINT 'clean.dim_store loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ── B4. clean.fact_orders ────────────────────────────────────
-- Rules:
--   1. Deduplicate on order_line_id → keep first occurrence
--   2. Convert discount_pct: '10%' → 0.10, '0' → 0.00
TRUNCATE TABLE clean.fact_orders;

WITH deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_line_id
               ORDER BY order_ts
           ) AS rn
    FROM raw.fact_orders
),
discount_fixed AS (
    SELECT *,
        CASE
            WHEN discount_pct LIKE '%[%]%'
                THEN CAST(REPLACE(discount_pct, '%', '') AS DECIMAL(5,2)) / 100.0
            WHEN TRY_CAST(discount_pct AS DECIMAL(5,4)) IS NOT NULL
                THEN CAST(discount_pct AS DECIMAL(5,4))
            ELSE 0.0
        END AS discount_pct_clean
    FROM deduped
    WHERE rn = 1
)
INSERT INTO clean.fact_orders
SELECT
    order_line_id,
    order_id,
    order_ts,
    store_id,
    customer_id,
    product_id,
    units,
    CAST(unit_price       AS DECIMAL(10,2)),
    CAST(cogs_per_unit    AS DECIMAL(10,2)),
    CAST(discount_amount  AS DECIMAL(10,2)),
    CAST(effective_revenue AS DECIMAL(10,2)),
    channel,
    order_status,
    CAST(is_promo AS BIT),
    discount_pct_clean
FROM discount_fixed;

PRINT 'clean.fact_orders loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ── B5. clean.fact_delivery ──────────────────────────────────
-- Rules:
--   1. Remove rows where pickup_ts < order_ts  (impossible timestamps)
--   2. Remove rows where actual_mins < 0  (sensor/data entry error)
--   3. Fill NULL actual_mins with DATEDIFF from order_ts → delivery_ts
--   4. Standardise is_rainy: 'Yes'/'1'/1 → 1, everything else → 0
TRUNCATE TABLE clean.fact_delivery;

INSERT INTO clean.fact_delivery
SELECT
    delivery_id,
    order_id,
    store_id,
    rider_id,
    order_ts,
    pickup_ts,
    delivery_ts,
    promised_mins,
    COALESCE(
        CASE WHEN actual_mins < 0 THEN NULL ELSE actual_mins END,
        CAST(DATEDIFF(MINUTE, order_ts, delivery_ts) AS DECIMAL(8,2))
    )                   AS actual_mins,
    pick_pack_mins,
    CAST(distance_km AS DECIMAL(6,2)),
    CAST(is_late  AS BIT),
    CAST(
        CASE
            WHEN UPPER(LTRIM(RTRIM(CAST(is_rainy AS NVARCHAR(10))))) IN ('YES','1','TRUE') THEN 1
            ELSE 0
        END AS BIT
    )                   AS is_rainy
FROM raw.fact_delivery
WHERE pickup_ts >= order_ts      -- remove impossible timestamps
  AND (actual_mins IS NULL OR actual_mins >= 0);  -- keep NULLs (filled above) or valid

PRINT 'clean.fact_delivery loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
SELECT * FROM clean.fact_delivery

-- ── B6. clean.fact_inventory ─────────────────────────────────
-- Rules:
--   1. Remove negative stock_on_hand
--   2. Deduplicate on (inventory_date, store_id, product_id) → keep MAX stock
TRUNCATE TABLE clean.fact_inventory;

INSERT INTO clean.fact_inventory
SELECT
    inventory_date,
    store_id,
    product_id,
    MAX(stock_on_hand)          AS stock_on_hand   -- keep highest reading per day
FROM raw.fact_inventory
WHERE stock_on_hand >= 0
GROUP BY inventory_date, store_id, product_id;

PRINT 'clean.fact_inventory loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ── B7. clean.fact_promotions ────────────────────────────────
-- Already deduplicated in source after orphan removal; straight load
TRUNCATE TABLE clean.fact_promotions;

INSERT INTO clean.fact_promotions
SELECT
    promo_date,
    store_id,
    product_id,
    CAST(is_promo AS BIT),
    CAST(discount_pct AS DECIMAL(5,4))
FROM raw.fact_promotions;

PRINT 'clean.fact_promotions loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';

-- ── B8. clean.festival_calendar ──────────────────────────────
-- Rules:
--   1. Parse both date formats into DATE type
--   2. TRIM trailing spaces from festival_name
TRUNCATE TABLE clean.festival_calendar;

WITH parsed AS (
    SELECT
        CASE
            WHEN date LIKE '[0-3][0-9]-[0-1][0-9]-[0-9][0-9][0-9][0-9]'
                THEN CONVERT(DATE,
                        SUBSTRING(date,7,4) + '-' +
                        SUBSTRING(date,4,2) + '-' +
                        SUBSTRING(date,1,2),
                     23)
            ELSE TRY_CAST(date AS DATE)
        END                                 AS festival_date,
        LTRIM(RTRIM(festival_name))         AS festival_name,
        CAST(is_festival_window AS BIT)     AS is_festival_window,
        days_from_festival,

        -- Keep only one row per date
        ROW_NUMBER() OVER (
            PARTITION BY
                CASE
                    WHEN date LIKE '[0-3][0-9]-[0-1][0-9]-[0-9][0-9][0-9][0-9]'
                        THEN CONVERT(DATE,
                                SUBSTRING(date,7,4) + '-' +
                                SUBSTRING(date,4,2) + '-' +
                                SUBSTRING(date,1,2),
                             23)
                    ELSE TRY_CAST(date AS DATE)
                END
            ORDER BY date
        ) AS rn
    FROM raw.festival_calendar
    WHERE TRY_CAST(date AS DATE) IS NOT NULL
       OR date LIKE '[0-3][0-9]-[0-1][0-9]-[0-9][0-9][0-9][0-9]'
)
INSERT INTO clean.festival_calendar
SELECT
    festival_date,
    festival_name,
    is_festival_window,
    days_from_festival
FROM parsed
WHERE rn = 1
  AND festival_date IS NOT NULL;

PRINT 'clean.festival_calendar loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';


-- ── B9. Referential Integrity Check ──────────────────────────
PRINT '========== REFERENTIAL INTEGRITY CHECK ==========';

--Check 1: Orders with missing customers
SELECT 'fact_orders → dim_customer orphans' AS check_name,
       COUNT(*) AS cnt
FROM clean.fact_orders fo
LEFT JOIN clean.dim_customer dc ON fo.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL;
--Check 1: Orders with missing Stores
SELECT 'fact_orders → dim_store orphans' AS check_name,
       COUNT(*) AS cnt
FROM clean.fact_orders fo
LEFT JOIN clean.dim_store ds ON fo.store_id = ds.store_id
WHERE ds.store_id IS NULL;

SELECT 'fact_orders → dim_product orphans' AS check_name,
       COUNT(*) AS cnt
FROM clean.fact_orders fo
LEFT JOIN clean.dim_product dp ON fo.product_id = dp.product_id
WHERE dp.product_id IS NULL;

PRINT 'Data cleaning complete. Clean tables are ready for analysis.';
GO
