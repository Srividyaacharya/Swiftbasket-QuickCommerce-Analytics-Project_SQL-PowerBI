# 🛒 SwiftBasket Quick Commerce — SQL Analytics Project

![SQL Server](https://img.shields.io/badge/SQL%20Server-2022-blue?logo=microsoftsqlserver)
![SSMS](https://img.shields.io/badge/SSMS-22-blue?logo=microsoft)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Domain](https://img.shields.io/badge/Domain-Quick%20Commerce-orange)
![Rows](https://img.shields.io/badge/Data-450K%2B%20rows-lightgrey)

---

## 📌 Project Overview

SwiftBasket is a simulated **hyperlocal grocery delivery company** operating
40 dark stores across Bengaluru — similar to Blinkit, Zepto, or Swiggy Instamart.

This project demonstrates a **complete SQL analytics workflow:**

```
Raw Messy Data  →  Data Audit  →  Data Cleaning  →  Business Analysis
```

> 💡 The data was intentionally made messy to simulate real-world scenarios.
> All 13 issues were detected, documented, and fixed using SQL Server 2022.

---

## 🗂️ Repository Structure

```
swiftbasket-sql-portfolio/
│
├── 📁 data/
│   └── raw/                        ← 8 messy CSV files (source data)
│
├── 📁 sql/
│   ├── 01_create_schema.sql        ← Creates raw + clean schemas & tables
│   ├── 02_data_cleaning.sql        ← Audits issues + loads clean tables
│   └── 03_analysis.sql             ← 5 business problem queries
│
├── 📁 screenshots/
│   ├── audit_results.png
│   ├── schema_structure.png
│   ├── problem1_retention.png
│   ├── problem2_delivery.png
│   ├── problem3_promo.png
│   ├── problem4_inventory.png
│   └── problem5_festival.png
│
└── README.md
```

---

## 🏗️ Architecture

```
raw.*  schema               clean.*  schema
─────────────               ───────────────
Original messy data    →    Cleaned trusted data
Never modified              Used for all analysis
Audit trail preserved       Query ready
```

This mirrors the **Medallion Architecture** used in industry:

| Industry Term | This Project | Purpose |
|---|---|---|
| Bronze Layer | `raw.*` schema | Store original data as-is |
| Silver Layer | `clean.*` schema | Cleaned, standardised data |
| Gold Layer | Analysis queries | Business insights |

---

## 📊 Data Dictionary

### `dim_customer` — Customer Master
> One row per customer. 6,000 customers across Bengaluru.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `customer_id` | VARCHAR | Unique customer identifier | `CUST_0001` |
| `city` | VARCHAR | Customer's city | `Bengaluru` |
| `locality` | VARCHAR | Neighbourhood within city | `Koramangala` |
| `age_group` | VARCHAR | Age bracket of customer | `25-34` |
| `acquisition_channel` | VARCHAR | How customer was acquired | `Referral`, `Organic`, `Paid` |
| `signup_date` | DATE | Date customer registered | `2025-09-15` |
| `is_app_user` | BIT | 1 = uses mobile app, 0 = web only | `1` |

---

### `dim_product` — Product Master
> One row per product. 40 SKUs across 8 categories.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `product_id` | VARCHAR | Unique product identifier | `PROD_001` |
| `product_name` | VARCHAR | Full product name | `Amul Taza Milk 1L` |
| `category` | VARCHAR | Product category | `Dairy` |
| `sub_category` | VARCHAR | Product sub-category | `Milk` |
| `base_price` | DECIMAL | Selling price in ₹ | `62.00` |
| `is_perishable` | BIT | 1 = perishable item | `1` |
| `reorder_point_units` | INT | Minimum stock before reorder triggered | `50` |

---

### `dim_store` — Store Master
> One row per store. 40 dark stores across 5 Bengaluru zones.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `store_id` | VARCHAR | Unique store identifier | `STORE_01` |
| `store_name` | VARCHAR | Store name | `SwiftBasket Koramangala` |
| `city` | VARCHAR | City | `Bengaluru` |
| `locality` | VARCHAR | Store neighbourhood | `Koramangala` |
| `zone` | VARCHAR | Bengaluru zone | `South`, `North`, `East` |
| `tier` | INT | Store tier number (1=best) | `1` |
| `tier_label` | VARCHAR | Tier description | `Premium`, `Standard` |
| `latitude` | FLOAT | GPS latitude | `12.9352` |
| `longitude` | FLOAT | GPS longitude | `77.6245` |
| `store_open_date` | DATE | Date store started operations | `2025-06-01` |

---

### `fact_orders` — Order Lines
> One row per product per order. ~62,000 rows.
> An order with 3 products = 3 rows with the same `order_id`.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `order_line_id` | VARCHAR | Unique identifier per order line | `OL_00001` |
| `order_id` | VARCHAR | Order identifier (groups lines) | `ORD_0001` |
| `order_ts` | DATETIME2 | Timestamp when order was placed | `2025-12-05 14:32:00` |
| `store_id` | VARCHAR | Store that fulfilled the order | `STORE_01` |
| `customer_id` | VARCHAR | Customer who placed the order | `CUST_0001` |
| `product_id` | VARCHAR | Product ordered | `PROD_001` |
| `units` | INT | Quantity ordered | `2` |
| `unit_price` | DECIMAL | Price per unit in ₹ | `62.00` |
| `cogs_per_unit` | DECIMAL | Cost of goods per unit in ₹ | `48.00` |
| `discount_amount` | DECIMAL | Total discount applied in ₹ | `6.20` |
| `effective_revenue` | DECIMAL | Actual revenue after discount in ₹ | `117.80` |
| `channel` | VARCHAR | How order was placed | `app`, `web` |
| `order_status` | VARCHAR | Final order status | `delivered`, `cancelled` |
| `is_promo` | BIT | 1 = promo applied on this line | `1` |
| `discount_pct` | DECIMAL | Discount percentage applied | `0.10` |

---

### `fact_delivery` — Delivery Records
> One row per delivery. ~21,000 rows.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `delivery_id` | VARCHAR | Unique delivery identifier | `DEL_00001` |
| `order_id` | VARCHAR | Linked order | `ORD_0001` |
| `store_id` | VARCHAR | Store that dispatched | `STORE_01` |
| `rider_id` | VARCHAR | Delivery rider identifier | `RIDER_01` |
| `order_ts` | DATETIME2 | When order was placed | `2025-12-05 14:32:00` |
| `pickup_ts` | DATETIME2 | When rider picked up from store | `2025-12-05 14:45:00` |
| `delivery_ts` | DATETIME2 | When order reached customer | `2025-12-05 15:02:00` |
| `promised_mins` | INT | SLA commitment in minutes | `30` |
| `actual_mins` | DECIMAL | Actual delivery time in minutes | `27.5` |
| `pick_pack_mins` | INT | Time to pick and pack at store | `8` |
| `distance_km` | DECIMAL | Delivery distance in km | `2.3` |
| `is_late` | BIT | 1 = breached 30-min SLA | `0` |
| `is_rainy` | BIT | 1 = rainy weather at delivery time | `1` |

---

### `fact_inventory` — Daily Stock Levels
> One row per store per product per day. ~192,000 rows.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `inventory_date` | DATE | Date of stock count | `2025-12-05` |
| `store_id` | VARCHAR | Store identifier | `STORE_01` |
| `product_id` | VARCHAR | Product identifier | `PROD_001` |
| `stock_on_hand` | INT | Units in stock at end of day | `145` |

---

### `fact_promotions` — Promotion Schedule
> One row per store per product per day when a promo is active. ~189,000 rows.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `promo_date` | DATE | Date promotion is active | `2025-12-25` |
| `store_id` | VARCHAR | Store running the promo | `STORE_01` |
| `product_id` | VARCHAR | Product on promotion | `PROD_005` |
| `is_promo` | BIT | 1 = promo active | `1` |
| `discount_pct` | DECIMAL | Discount percentage offered | `0.15` |

---

### `festival_calendar` — Indian Festival Calendar
> One row per date in festival window. 43 rows covering major festivals.

| Column | Data Type | Description | Example |
|---|---|---|---|
| `festival_date` | DATE | Calendar date | `2025-12-25` |
| `festival_name` | VARCHAR | Name of the festival | `Christmas` |
| `is_festival_window` | BIT | 1 = within 3 days of festival | `1` |
| `days_from_festival` | INT | -3 to +3 (0 = festival day itself) | `-2` |

> `days_from_festival` key:
> `-3` = 3 days before · `-1` = 1 day before · `0` = festival day · `1` = day after

---

## 🧹 Data Quality Issues — Before & After

| # | Table | Problem | Fix |
|---|---|---|---|
| 1 | `dim_customer` | Mixed case — `referral`/`REFERRAL`/`Referral` | `UPPER(LTRIM(RTRIM(...)))` |
| 2 | `dim_customer` | NULL `city` for ~5% of customers | `COALESCE` with store city lookup |
| 3 | `dim_customer` | 150 duplicate customer rows | `ROW_NUMBER() PARTITION BY customer_id` |
| 4 | `fact_orders` | `discount_pct` as `'10%'` string vs `0.10` float | `REPLACE + CAST + CASE WHEN` |
| 5 | `fact_orders` | 200 duplicate `order_line_id` rows | `ROW_NUMBER() PARTITION BY order_line_id` |
| 6 | `fact_delivery` | Negative `actual_mins` values | `WHERE actual_mins >= 0` |
| 7 | `fact_delivery` | `pickup_ts` before `order_ts` — impossible | `WHERE pickup_ts >= order_ts` |
| 8 | `fact_delivery` | `is_rainy` as `'Yes'/'No'/'1'/'0'` mixed | `CASE WHEN UPPER(...)` |
| 9 | `fact_inventory` | Negative `stock_on_hand` values | `WHERE stock_on_hand >= 0` |
| 10 | `fact_inventory` | 500 duplicate rows same store+product+date | `GROUP BY ... MAX(stock_on_hand)` |
| 11 | `dim_product` | NULL `reorder_point_units` for 8 products | `COALESCE` with category median |
| 12 | `festival_calendar` | Mixed date formats `DD-MM-YYYY` vs `YYYY-MM-DD` | `SUBSTRING + CONVERT` |
| 13 | `festival_calendar` | Trailing spaces in `festival_name` | `LTRIM(RTRIM(...))` |

### Audit Results
![Audit](Screenshots/audit_results.png)

### Schema Structure
![Schema](Screenshots/schema_structure.png)

---

## 🔍 5 Business Problems Solved

### Problem 1 — Customer Cohort & Retention
**Question:** Which acquisition channel retains customers the longest?

**Approach:**
- Built monthly cohort — grouped customers by month of first order
- Tracked how many stayed active each month after joining
- Calculated 3-month rolling retention rate per channel

##  Key Insights

  <img width="1332" height="642" alt="image" src="https://github.com/user-attachments/assets/7ee2be5b-8a87-45c0-98ea-e1ddc039e796" />
  
- Customer retention drops significantly during the first month across all acquisition channels, declining from **100% to 47–68%**, before stabilizing around **49–63%** in subsequent months.
- **Paid App Install** was the best-performing channel, achieving **67.7% Month-1 retention** and **62.5% Month-3 retention**.
- **Referral** and **Organic** channels demonstrated strong long-term retention (**60.0%** and **60.7%** Month-3 retention respectively).
- **Word of Mouth** customers showed strong engagement despite lower acquisition volume.
- **Influencer** campaigns generated high acquisition volume but experienced a gradual decline in retention over time.
- **Coupon** acquisitions showed the weakest retention performance, indicating discount-driven purchasing behavior.

---

##  Business Recommendations

- Improve customer engagement during the **first 30 days**, where the highest churn occurs.
- Increase investment in **Paid App Install, Organic, and Referral** channels.
- Expand the **Referral Program** to drive scalable customer growth.
- Evaluate **Influencer campaigns** at the creator level and scale high-performing partnerships.
- Reassess **Coupon-based acquisition strategies** and focus on loyalty-driven incentives.
- Continue monitoring newer cohorts before making major budget allocation decisions.

![Problem 1](Screenshots/problem1_retention.png)

---

### Problem 2 — Delivery SLA & Rider Performance
**Question:** Which riders have the worst late delivery rate on rainy days?

**Approach:**
- Calculated late % per rider split by rainy vs dry day
- Filtered to riders with 10+ deliveries using `HAVING`
- Ranked worst 5 per store with `RANK() PARTITION BY store_id`
- Flagged root cause: Distance+Rain vs Ops Issue

## Key Insights

- Delivery delays during rainy conditions were **not caused by distance**, as average delivery distances across all stores ranged from only **1.4–2.7 km**.
- **100% of riders** experienced SLA breaches on rainy days, indicating a systemic operational issue rather than individual rider performance.
- **S003 (Whitefield)** showed the poorest performance, with rider **R048 averaging 52.9 minutes** per delivery despite traveling only **2.66 km**.
- **S002 (Koramangala)** had **6 riders with 100% late-delivery rates**, suggesting a potential store-level bottleneck.
- Pick-pack times remained consistent at **4–6 minutes** across all stores, indicating that order preparation was not the primary cause of delays.
- The evidence suggests that rainy-weather operations and last-mile execution, rather than delivery distance or order preparation, are the key drivers of SLA failures.

---

## Business Recommendations

- Implement a **weather-adjusted SLA** to account for unavoidable delays during rainy conditions.
- Investigate operational inefficiencies in **S003 (Whitefield)**, particularly rider **R048**, to identify root causes.
- Conduct a process audit at **S002 (Koramangala)** to uncover dispatch, handoff, or rider allocation bottlenecks.
- Analyze best practices from relatively better-performing riders and standardize successful delivery approaches across stores.
- Separate **weather-related delays** from standard SLA reporting to improve performance measurement and operational decision-making.

**SQL:** Conditional aggregation · `HAVING` · `RANK() OVER (PARTITION BY)`

![Problem 2](Screenshots/problem2_delivery.png)

---

### Problem 3 — Promo Effectiveness & Margin Impact
**Question:** Which promotions drove real uplift vs just margin giveaway?

**Approach:**
- Compared promo vs non-promo sales baseline per product
- Calculated ROI = gross margin ÷ discount given
- Detected orphan orders using `LEFT JOIN` null check
- Classified: Star Promo / Volume Only / Poor ROI

## Key Insights

- Most promotions fell into **"Efficient"** or **"Poor ROI"** categories, indicating that many campaigns either generated limited volume growth or failed to deliver profitable returns.
- **Star Promos** were rare but highly effective, with products like **Butter 100g, Breakfast Cereal, and Biscuits Pack** achieving both strong ROI and significant volume uplift.
- Core stores (**S001–S004**) consistently delivered higher promotional ROI, while several peripheral stores (**S018–S040**) experienced low or negative returns.
- Beverage and staple categories generated high promotional activity but showed limited incremental sales, suggesting potential discount leakage.
- Protein products such as **Chicken and Eggs** frequently produced low ROI and margin erosion, particularly in lower-volume stores.

---

## Business Recommendations

- Scale high-performing **Star Promos** across similar stores and product categories.
- Reduce or redesign promotions in stores with consistently low ROI and negative margins.
- Establish a minimum **ROI threshold (e.g., 2x)** before approving promotional campaigns.
- Audit "Efficient" promotions to identify discount leakage and optimize pricing strategies.
- Replace blanket discounts with **bundling and loyalty-based offers**, especially for beverage and staple categories.
- Limit deep discounting on high-cost protein products in low-volume stores.

**SQL:** Multi-CTE pipeline · `LEFT JOIN` orphan detection · ROI formula

![Problem 3](Screenshots/problem3_promo.png)

---

### Problem 4 — Inventory Stockout Risk
**Question:** Which store–product combos will stock out within 5 days?

**Approach:**
- Calculated avg daily sales velocity (last 30 days)
- Got latest stock snapshot using `ROW_NUMBER()` on inventory date
- Compared stock vs reorder point per product
- Generated risk tiers + recommended reorder quantity

## Key Insights

- Stockout risk is heavily concentrated in **Struggling-tier stores**, with several locations experiencing multiple simultaneous stockouts across essential products.
- Over **80 products** were classified as **Stockout** or **Critical (≤2 days remaining)**, indicating systemic inventory management issues rather than isolated supply disruptions.
- Perishable products such as **Milk, Eggs, Butter, Bananas, and Curd** accounted for a significant share of stockouts, increasing the risk of lost sales and customer dissatisfaction.
- More than **40 store-product combinations** had missing sales history (`avg_daily_units_sold = NULL`), preventing accurate demand forecasting and replenishment planning.
- Star-performing stores generally maintained healthy inventory levels, though a few high-demand products showed low stock coverage and require proactive monitoring.

---
## Business Recommendations

- Prioritize emergency replenishment for stores with multiple critical stockouts, focusing first on perishable and high-demand products.
- Resolve missing sales data issues to improve forecast accuracy and inventory planning.
- Implement more frequent replenishment cycles for struggling stores, particularly for perishable items.
- Restrict promotional campaigns on products or stores experiencing active stockouts.
- Review low-volume SKUs in underperforming stores and consider assortment optimization to reduce inventory carrying costs.

**SQL:** Velocity calc · `ROW_NUMBER()` latest snapshot · risk tier `CASE WHEN`

![Problem 4](Screenshots/problem4_inventory.png)

---

### Problem 5 — Festival Demand Spike
**Question:** Which categories spike most before festivals?

**Approach:**
- Tagged each order date with festival context via range join
- Calculated spike % vs normal daily baseline
- Ranked categories by spike per festival
## Key Insights

- **Republic Day** and **Makar Sankranti** generated the highest demand spikes across categories, outperforming traditionally prioritized events like Christmas and New Year.
- **Protein** and **Frozen** categories showed the strongest and most consistent festival-driven demand increases, often exceeding **100% above baseline sales**.
- **Beverages** maintained the highest revenue share across most festivals, making it the most critical category for revenue protection during peak demand periods.
- **Personal Care** and **Home Care** experienced significant spikes during festivals, reflecting increased household preparation and social gathering activities.
- **Bakery** emerged as an unexpectedly high-growth category during multiple festivals, indicating underappreciated demand potential.
- **Spreads** consistently delivered the lowest festival uplift and contributed minimally to incremental demand.

---

## Business Recommendations

- Build festival-specific inventory plans using historical demand multipliers and maintain additional safety stock for high-spike categories.
- Prioritize **Protein, Frozen, and Beverages** for pre-festival replenishment to prevent stockouts during peak demand periods.
- Increase inventory allocation 5–7 days before **Republic Day, Makar Sankranti, Holi, and Ugadi**, which showed the strongest demand surges.
- Avoid running promotions on categories already experiencing strong organic festival demand to protect margins.
- Use historical festival demand data to improve supplier planning and secure inventory commitments ahead of peak periods.

**SQL:** Range joins · `RANK() PARTITION BY festival_name` · % of total window function

![Problem 5](Screenshots/problem5_festival.png)

---
## SQL Skills Demonstrated

- Data Cleaning & Validation
- Cohort Retention Analysis
- Window Functions (`ROW_NUMBER`, `RANK`, `AVG OVER`)
- Rolling Retention Metrics
- Conditional Aggregation
- Inventory Risk Analysis
- Promotion ROI Analysis
- Delivery SLA Analytics
- Festival Demand Forecasting
- Multi-Step CTE Pipelines
- Business KPI Development

---

## ▶️ How to Run

**Prerequisites:** SQL Server 2022 · SSMS 22

```
1. Run 01_create_schema.sql    → creates database + all tables
2. Load CSVs via BULK INSERT   → populates raw.* tables
3. Run 02_data_cleaning.sql    → Section A (audit) then Section B (clean)
4. Run 03_analysis.sql         → one problem at a time
```

---

## 👤 About

**Name:** Srividya
**LinkedIn:** www.linkedin.com/in/srividya-achar
**Email:** SrividyaAchar@outlook.com
> 🔗 Also see: [SwiftBasket Power BI Dashboard →](../swiftbasket-powerbi-dashboard)

---
*SQL Portfolio Project | SQL Server 2022 | SSMS 22*
