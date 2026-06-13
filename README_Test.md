# SwiftBasket Quick Commerce SQL Portfolio Project

This project simulates a quick-commerce analytics workflow in **SQL Server 2022** for **SwiftBasket**, a grocery delivery business. It covers the full pipeline from raw CSV ingestion and schema design to data cleaning and business analysis across customers, delivery operations, promotions, inventory, and festival demand.

## Business Problem

SwiftBasket needs a reliable analytics layer to answer core business questions:

- Which customer acquisition channels drive better retention and repeat purchases?
- Which stores and riders are causing delivery SLA breaches, especially during rain?
- Which promotions generate profitable uplift versus margin leakage?
- Which store-product combinations are at immediate stockout risk?
- Which product categories spike before festivals and need better demand planning?

The goal is to turn messy operational data into decision-ready insights that improve growth, service quality, inventory planning, and profitability.

## Dataset

The project uses **8 raw tables** loaded from CSV files into a `raw` schema:

| Table | Description |
| --- | --- |
| `raw.dim_customer` | Customer profile, geography, signup, acquisition channel |
| `raw.dim_product` | Product, category, price, perishability, reorder point |
| `raw.dim_store` | Store location, zone, tier, and opening date |
| `raw.fact_orders` | Order lines, pricing, discount, promo, and status data |
| `raw.fact_delivery` | Delivery timestamps, SLA, rider, distance, weather flag |
| `raw.fact_inventory` | Daily stock snapshots by store and product |
| `raw.fact_promotions` | Product-store-date promotion records |
| `raw.festival_calendar` | Festival dates and demand-window markers |

The cleaned analytics layer is built in a separate `clean` schema with standardized types, deduplicated records, and corrected business logic.

## Approach

The project is structured as a realistic SQL workflow:

1. **Schema creation** - `01_create_schema.sql` creates the `SwiftBasket` database, `raw` and `clean` schemas, and all source and target tables.
2. **Raw data loading** - `BULKINSERT.sql` loads CSV files into the raw tables.
3. **Data quality audit and cleaning** - `02_data_cleaning.sql` audits raw data issues, applies cleaning rules, and loads trusted records into the `clean` schema.
4. **Business analysis** - `03_analysis.sql` solves five business problems using only clean tables.

## Data Cleaning Highlights

The cleaning layer addresses common real-world data quality issues:

- Duplicate `customer_id`, `order_line_id`, and inventory snapshot rows
- Mixed text formats such as acquisition channels and rainy-day flags
- Mixed `%` and decimal formats in `discount_pct`
- Null or invalid values such as missing reorder points and negative delivery times
- Impossible timestamps such as `pickup_ts < order_ts`
- Mixed date formats in the festival calendar
- Basic referential integrity checks across orders, customers, stores, and products

## SQL Techniques

This project demonstrates practical analytics SQL techniques, including:

- **CTEs** for stepwise logic and reusable transformations
- **Window functions** such as `ROW_NUMBER()`, `RANK()`, and rolling averages
- **Conditional aggregation** with `CASE WHEN`
- **Date functions** including `DATEDIFF`, `DATEADD`, and `DATEFROMPARTS`
- **Data standardization** with `TRY_CAST`, `TRY_CONVERT`, `LTRIM`, `RTRIM`, `UPPER`, and `COALESCE`
- **Median imputation** using `PERCENTILE_CONT`
- **Deduplication logic** using partitioned ranking
- **Join-based analysis** across customer, store, product, delivery, inventory, and promotion facts
- **Business KPI calculations** such as retention, late-delivery rate, volume uplift, promo ROI, and stockout risk

## Insights

The analysis layer is designed to surface actionable insights in five areas:

### 1. Customer retention and cohort behavior
- Identifies which acquisition channels retain customers longer
- Compares repeat activity by cohort month and channel
- Highlights where customer quality differs by acquisition source and city

### 2. Delivery SLA performance
- Ranks stores and riders with the highest late-delivery rates on rainy days
- Separates distance-driven delays from operational inefficiencies
- Exposes delivery bottlenecks in pick-pack versus last-mile execution

### 3. Promotion effectiveness
- Distinguishes true volume-generating promotions from discount-heavy margin giveaways
- Measures promo ROI by store and product combination
- Classifies promotions into high-value and low-value groups

### 4. Inventory risk and reorder planning
- Flags stockouts, critical low-stock items, and reorder-needed products
- Estimates days until stockout using recent sales velocity
- Suggests reorder quantities to maintain short-term coverage

### 5. Festival demand spikes
- Detects product categories with pre-festival demand surges
- Compares festival-period demand against normal baseline demand
- Supports stocking strategy ahead of seasonal spikes

## Business Impact

If implemented in a live quick-commerce environment, these analyses help the business:

- **Improve retention** by investing in acquisition channels that bring higher-quality customers
- **Reduce SLA breaches** by targeting underperforming stores, riders, and rainy-day operations
- **Protect margins** by scaling only promotions that create profitable uplift
- **Prevent lost sales** by identifying stockout risks before they hit availability
- **Plan seasonal demand better** by stocking festival-sensitive categories in advance

## Files

| File | Purpose |
| --- | --- |
| `01_create_schema.sql` | Creates database, schemas, and all raw/clean tables |
| `BULKINSERT.sql` | Loads CSV data into raw tables using `BULK INSERT` |
| `02_data_cleaning.sql` | Audits raw data, cleans issues, and populates clean tables |
| `03_analysis.sql` | Runs five business analyses on the clean schema |

## How to Run

1. Run `01_create_schema.sql`
2. Update file paths in `BULKINSERT.sql` if needed, then run it
3. Run `02_data_cleaning.sql`
4. Run `03_analysis.sql`

## Tools Used

- **SQL Server 2022**
- **T-SQL**
- **BULK INSERT**
- **Window functions and analytical SQL**

---

This project is built as a portfolio-ready example of turning raw operational data into a clean analytical model and business-focused SQL insights.
