-- ============================================================
-- SwiftBasket Quick Commerce | SQL Portfolio Project
-- FILE: 01_create_schema.sql
-- PURPOSE: Create database and all raw + clean table schemas
-- SQL Server 2022
-- ============================================================

-- ── Create Database ──────────────────────────────────────────
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'SwiftBasket')
    CREATE DATABASE SwiftBasket;
GO

USE SwiftBasket;
GO

-- ============================================================
-- RAW TABLES  (data as imported, no cleaning applied)
-- ============================================================

-- Raw: dim_customer
IF OBJECT_ID('raw.dim_customer', 'U') IS NOT NULL DROP TABLE raw.dim_customer;
GO
CREATE SCHEMA raw;
GO

CREATE TABLE raw.dim_customer (
    customer_id         NVARCHAR(20),
    city                NVARCHAR(100),
    locality            NVARCHAR(100),
    age_group           NVARCHAR(20),
    acquisition_channel NVARCHAR(50),    -- DIRTY: mixed case (REFERRAL, referral, Referral)
    signup_date         NVARCHAR(30),    -- stored as text to preserve import
    is_app_user         NVARCHAR(5)      -- DIRTY: duplicates exist with slight date diff
);

-- Raw: dim_product
IF OBJECT_ID('raw.dim_product', 'U') IS NOT NULL DROP TABLE raw.dim_product;
CREATE TABLE raw.dim_product (
    product_id              NVARCHAR(10),
    product_name            NVARCHAR(100),
    category                NVARCHAR(50),
    base_price              FLOAT,
    sub_category            NVARCHAR(100),
    is_perishable           INT,
    reorder_point_units     FLOAT       -- DIRTY: NULLs for 8 products
);

-- Raw: dim_store
IF OBJECT_ID('raw.dim_store', 'U') IS NOT NULL DROP TABLE raw.dim_store;
CREATE TABLE raw.dim_store (
    store_id            NVARCHAR(10),
    store_name          NVARCHAR(150),
    city                NVARCHAR(100),
    locality            NVARCHAR(100),
    zone                NVARCHAR(20),
    tier                INT,
    tier_label          NVARCHAR(20),
    latitude            FLOAT,
    longitude           FLOAT,
    store_open_date     DATE
);

-- Raw: fact_orders
IF OBJECT_ID('raw.fact_orders', 'U') IS NOT NULL DROP TABLE raw.fact_orders;
CREATE TABLE raw.fact_orders (
    order_line_id       NVARCHAR(30),   -- DIRTY: ~200 duplicate rows
    order_id            NVARCHAR(20),
    order_ts            DATETIME2,
    store_id            NVARCHAR(10),
    customer_id         NVARCHAR(20),
    product_id          NVARCHAR(10),
    units               INT,
    unit_price          FLOAT,
    cogs_per_unit       FLOAT,
    discount_amount     FLOAT,
    effective_revenue   FLOAT,
    channel             NVARCHAR(20),
    order_status        NVARCHAR(30),
    is_promo            INT,
    discount_pct        NVARCHAR(10)    -- DIRTY: mix of '10%' string and 0.10 float
);

-- Raw: fact_delivery
IF OBJECT_ID('raw.fact_delivery', 'U') IS NOT NULL DROP TABLE raw.fact_delivery;
CREATE TABLE raw.fact_delivery (
    delivery_id         NVARCHAR(20),
    order_id            NVARCHAR(20),
    store_id            NVARCHAR(10),
    rider_id            NVARCHAR(10),
    order_ts            DATETIME2,
    pickup_ts           DATETIME2,      -- DIRTY: some pickup_ts < order_ts
    delivery_ts         DATETIME2,
    promised_mins       INT,
    actual_mins         FLOAT,          -- DIRTY: some negatives, some NULLs
    pick_pack_mins      INT,
    distance_km         FLOAT,
    is_late             INT,
    is_rainy            NVARCHAR(5)     -- DIRTY: 'Yes'/'No'/'1'/'0'/1/0 mixed
);

-- Raw: fact_inventory
IF OBJECT_ID('raw.fact_inventory', 'U') IS NOT NULL DROP TABLE raw.fact_inventory;
CREATE TABLE raw.fact_inventory (
    inventory_date      DATE,
    store_id            NVARCHAR(10),
    product_id          NVARCHAR(10),
    stock_on_hand       INT             -- DIRTY: some negatives, ~500 duplicate rows
);

-- Raw: fact_promotions
IF OBJECT_ID('raw.fact_promotions', 'U') IS NOT NULL DROP TABLE raw.fact_promotions;
CREATE TABLE raw.fact_promotions (
    promo_date          DATE,
    store_id            NVARCHAR(10),
    product_id          NVARCHAR(10),
    is_promo            INT,
    discount_pct        FLOAT           -- DIRTY: ~10% of promo records removed (orphans)
);

-- Raw: festival_calendar
IF OBJECT_ID('raw.festival_calendar', 'U') IS NOT NULL DROP TABLE raw.festival_calendar;
CREATE TABLE raw.festival_calendar (
    date                NVARCHAR(30),   -- DIRTY: mix of YYYY-MM-DD and DD-MM-YYYY strings
    festival_name       NVARCHAR(100),  -- DIRTY: trailing spaces '  '
    is_festival_window  INT,
    days_from_festival  INT
);

-- ============================================================
-- CLEAN TABLES  (created by 02_data_cleaning.sql)
-- ============================================================

CREATE SCHEMA clean;
GO

CREATE TABLE clean.dim_customer (
    customer_id         NVARCHAR(20)    NOT NULL,
    city                NVARCHAR(100),
    locality            NVARCHAR(100),
    age_group           NVARCHAR(20),
    acquisition_channel NVARCHAR(50),
    signup_date         DATE,
    is_app_user         BIT,
    CONSTRAINT PK_clean_customer PRIMARY KEY (customer_id)
);

CREATE TABLE clean.dim_product (
    product_id              NVARCHAR(10)    NOT NULL,
    product_name            NVARCHAR(100),
    category                NVARCHAR(50),
    base_price              DECIMAL(10,2),
    sub_category            NVARCHAR(100),
    is_perishable           BIT,
    reorder_point_units     INT,
    CONSTRAINT PK_clean_product PRIMARY KEY (product_id)
);

CREATE TABLE clean.dim_store (
    store_id            NVARCHAR(10)    NOT NULL,
    store_name          NVARCHAR(150),
    city                NVARCHAR(100),
    locality            NVARCHAR(100),
    zone                NVARCHAR(20),
    tier                INT,
    tier_label          NVARCHAR(20),
    latitude            FLOAT,
    longitude           FLOAT,
    store_open_date     DATE,
    CONSTRAINT PK_clean_store PRIMARY KEY (store_id)
);

CREATE TABLE clean.fact_orders (
    order_line_id       NVARCHAR(30)    NOT NULL,
    order_id            NVARCHAR(20),
    order_ts            DATETIME2,
    store_id            NVARCHAR(10),
    customer_id         NVARCHAR(20),
    product_id          NVARCHAR(10),
    units               INT,
    unit_price          DECIMAL(10,2),
    cogs_per_unit       DECIMAL(10,2),
    discount_amount     DECIMAL(10,2),
    effective_revenue   DECIMAL(10,2),
    channel             NVARCHAR(20),
    order_status        NVARCHAR(30),
    is_promo            BIT,
    discount_pct        DECIMAL(5,4),
    CONSTRAINT PK_clean_orders PRIMARY KEY (order_line_id)
);

CREATE TABLE clean.fact_delivery (
    delivery_id         NVARCHAR(20)    NOT NULL,
    order_id            NVARCHAR(20),
    store_id            NVARCHAR(10),
    rider_id            NVARCHAR(10),
    order_ts            DATETIME2,
    pickup_ts           DATETIME2,
    delivery_ts         DATETIME2,
    promised_mins       INT,
    actual_mins         DECIMAL(8,2),
    pick_pack_mins      INT,
    distance_km         DECIMAL(6,2),
    is_late             BIT,
    is_rainy            BIT,
    CONSTRAINT PK_clean_delivery PRIMARY KEY (delivery_id)
);

CREATE TABLE clean.fact_inventory (
    inventory_date      DATE            NOT NULL,
    store_id            NVARCHAR(10)    NOT NULL,
    product_id          NVARCHAR(10)    NOT NULL,
    stock_on_hand       INT,
    CONSTRAINT PK_clean_inventory PRIMARY KEY (inventory_date, store_id, product_id)
);

CREATE TABLE clean.fact_promotions (
    promo_date          DATE            NOT NULL,
    store_id            NVARCHAR(10)    NOT NULL,
    product_id          NVARCHAR(10)    NOT NULL,
    is_promo            BIT,
    discount_pct        DECIMAL(5,4),
    CONSTRAINT PK_clean_promotions PRIMARY KEY (promo_date, store_id, product_id)
);

CREATE TABLE clean.festival_calendar (
    festival_date       DATE            NOT NULL,
    festival_name       NVARCHAR(100),
    is_festival_window  BIT,
    days_from_festival  INT
   
);

PRINT 'Schema created successfully.';
GO
