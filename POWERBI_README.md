# 📊 SwiftBasket Quick Commerce — Power BI Dashboard

![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?logo=powerbi)
![DAX](https://img.shields.io/badge/DAX-Measures%20%26%20Columns-blue)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Domain](https://img.shields.io/badge/Domain-Quick%20Commerce-orange)
![Pages](https://img.shields.io/badge/Dashboard-7%20Pages-purple)

---

## 📌 Project Overview

This Power BI dashboard is the **visual analytics layer** of the SwiftBasket Quick Commerce project — built directly on top of the cleaned SQL data to turn query results into actionable business intelligence.

The dashboard covers **40 dark stores across Bengaluru**, analysing ₹1.07 Cr revenue, 23,119 orders, and 5,663 customers across a 4-month period (Dec 2025 – Mar 2026).

> 🔗 **SQL Project:** [SwiftBasket SQL Analytics →](../swiftbasket-sql-portfolio)

---

## 🏗️ Architecture

```
SQL Server (clean.* schema)
        ↓
Power BI Data Model
├── fact_orders        ← Order lines with revenue + margin
├── fact_delivery      ← Delivery records with SLA data
├── fact_inventory     ← Daily stock levels
├── fact_promotions    ← Promotion schedule
├── dim_customer       ← Customer master
├── dim_product        ← Product master (40 SKUs)
├── dim_store          ← Store master (40 stores, 4 tiers)
├── festival_calendar  ← Indian festival date windows
└── DateTable          ← Calendar with festival + rainy day flags
```

---

## 📐 Data Model

All relationships are **Many-to-One** from fact tables to dimension tables with single-direction cross-filtering. This ensures slicers on any dimension — tier, channel, zone, date — filter all visuals simultaneously.

| Relationship | Type |
|---|---|
| fact_orders → dim_customer | Many to One |
| fact_orders → dim_product | Many to One |
| fact_orders → dim_store | Many to One |
| fact_orders → DateTable | Many to One |
| fact_delivery → dim_store | Many to One |
| fact_inventory → dim_store | Many to One |
| fact_inventory → dim_product | Many to One |
| festival_calendar → DateTable | Many to One |

---

## 📋 Dashboard Pages

### Page 1 — Overview
**Business question:** How is the business performing overall?

| Visual | Insight |
|---|---|
| 5 KPI cards | ₹1.07Cr revenue · ₹39.9L gross profit · 23,119 orders · 5.5% cancellation · ₹17.3L stockout leakage |
| 7-day rolling avg line | Star+Good stores consistently outperform Average+Struggling |
| Revenue share donut | Good tier 39.45% · Star 23.43% · Average 28.34% · Struggling 8.78% |
| Orders by hour | Peak demand 8–9pm · Morning spike 8am |
| Orders by day | Sat/Sun +35–40% above weekday average |
| Order status funnel | 21,279 delivered · 1,264 cancelled · 576 failed |

**Key finding:** Struggling stores have 12% cancellation rate vs 2% for Star stores — same product, different ops execution.

---

### Page 2 — Store Performance
**Business question:** Which stores are winning and which are struggling?

| Visual | Insight |
|---|---|
| KPI cards by tier | Star ₹8.3L avg · Good ₹4.2L · Average ₹2.3L · Struggling ₹66.8K — 12.5x gap |
| All 40 stores ranked bar | Koramangala Zone A, HSR Layout Zone A, Indiranagar Zone A are top 3 |
| Fulfilment rate by tier | Star 97% · Good 94% · Average 90% · Struggling 82% |
| Store scorecard table | All 40 stores with revenue, margin, fulfilment, stockout rate |
| Revenue vs store age scatter | Older Star stores maintain higher revenue — maturity matters |

**Key finding:** The 12.5x revenue gap between Star and Struggling stores is not explained by location alone — ops quality is the differentiator.

---

### Page 3 — Profit & Margin
**Business question:** Where is margin being made and lost?

| Visual | Insight |
|---|---|
| Revenue and gross profit by tier | Good tier generates most absolute profit despite Star having higher per-store avg |
| Gross margin % by tier | Star 43.9% · Good 38.7% · Average 33.5% · Struggling 27.4% |
| Gross margin % by category | Personal Care 38.3% highest · Protein 37.0% lowest — very flat across categories |
| Gross margin trend line | **Struggling tier declining 29% → 25% over 4 months** — Star holding steady at 44% |

**Key finding:** Struggling stores are not just low revenue — their margin is actively deteriorating. Flat category margins suggest pricing is formulaic, not strategic.

---

### Page 4 — Inventory
**Business question:** Which products are at risk of stocking out?

| Visual | Insight |
|---|---|
| KPI cards | ₹1.07Cr revenue · ₹17.3L stockout leakage · 4.8% stockout rate |
| Near stockouts by tier | Struggling: 8,300 near-stockout events vs Star: near zero |
| Lost revenue by product | Chicken 1kg ₹163K · Breakfast Cereal ₹108K · Ice Cream ₹91K |
| Stockout rate by category | Bakery 6.3% · Protein 5.4% · Dairy 5.4% |
| **NEW: Inventory risk table** | Store × product drill-down with Risk Tier colour coding — STOCKOUT / CRITICAL / REORDER NEEDED / REVIEW |

**Key finding:** ₹17.3L in revenue lost to stockouts. Struggling stores have 8,300+ near-stockout events — systemic inventory management failure, not random supply disruption.

**DAX highlights:**
```dax
-- Latest stock snapshot per store-product
Is Latest Date = 
VAR MaxDate = MAXX(FILTER(fact_inventory, 
    fact_inventory[store_id] = EARLIER(fact_inventory[store_id]) &&
    fact_inventory[product_id] = EARLIER(fact_inventory[product_id])),
    fact_inventory[inventory_date])
RETURN IF(fact_inventory[inventory_date] = MaxDate, 1, 0)

-- Risk tier classification
Risk Tier = 
SWITCH(TRUE(),
    CurrentStock = 0,            "STOCKOUT",
    DaysLeft <= 2,               "CRITICAL (≤2 days)",
    DaysLeft <= 5,               "HIGH RISK (3-5 days)",
    DaysLeft = 999 && CurrentStock < ReorderPoint, "REORDER NEEDED",
    DaysLeft = 999,              "REVIEW (not selling)",
    CurrentStock < ReorderPoint, "REORDER NEEDED",
    "OK"
)
```

---

### Page 5 — Customer
**Business question:** Who are our customers and are we keeping them?

| Visual | Insight |
|---|---|
| KPI cards | 5,663 unique customers · 86.5% repeat rate · 4.08 avg orders · LTV₹5,642 estimated |
| **NEW: Retention heatmap matrix** | Green → Amber → Red showing all channels losing 40–50% of customers by month 3 |
| Top acquisition channels | Organic 28% · Referral 22% · Influencer 18% · Paid App Install 16% |
| Customers by age group | 25–34 age group = 42% of customers — core audience |

**Key finding:** 86.5% repeat rate is strong. But every acquisition channel loses 40–50% of customers by month 3 — the first 30 days is the critical intervention window.

**DAX highlights:**
```dax
-- Cohort month — month of first order per customer
Cohort Month = 
CALCULATE(MIN(fact_orders[order_ts]),
    ALLEXCEPT(fact_orders, fact_orders[customer_id]))

-- Retention % — core measure
Retention % = 
DIVIDE(
    DISTINCTCOUNT(fact_orders[customer_id]),
    CALCULATE(DISTINCTCOUNT(fact_orders[customer_id]),
        fact_orders[Month Offset] = 0,
        ALLEXCEPT(fact_orders, dim_customer[acquisition_channel]))
) * 100
```

---

### Page 6 — Delivery Ops
**Business question:** Are we delivering on time and what is slowing us down?

| Visual | Insight |
|---|---|
| KPI cards | 34.5% on-time rate · 45.9 min avg delivery · 5.0 min pick & pack · 2.85 km avg distance |
| Actual vs promised delivery by tier | Struggling: 50 promised vs 68 actual · Star: 30 promised vs 33 actual |
| On-time rate by store | Best store 38.6% — worst is well below industry standard of 85%+ |
| **NEW: On-time rate normal vs rainy** | Normal: Star 100%, Good 99%, Average 92%, Struggling 78% → Rainy: ALL tiers collapse to 2–6% |
| **NEW: Avg delivery time normal vs rainy** | Rain adds 20–40 minutes across every tier regardless of distance |

**Key finding:** Rain drops on-time rate from 99% to 4% — a 95 percentage point collapse. Distance is NOT the cause (avg 2.85km). Root cause is ops handoff failure in wet conditions.

**DAX highlights:**
```dax
On-Time Rate Rainy = 
DIVIDE(
    CALCULATE(COUNTROWS(fact_delivery),
        fact_delivery[is_late] = 0,
        fact_delivery[is_rainy] = 1),
    CALCULATE(COUNTROWS(fact_delivery),
        fact_delivery[is_rainy] = 1)
) * 100
```

---

### Page 7 — External Factors
**Business question:** How do weather and festivals affect demand and operations?

| Visual | Insight |
|---|---|
| KPI cards | +78% festival demand lift · -23.3% rainy day order drop · Star promo rate 6.9% · Struggling promo rate 24.2% |
| **NEW: Festival spike heatmap** | 12 categories × 7 festivals — Republic Day and Ugadi darkest green = biggest spikes |
| Festival lift by category | Frozen +91% · Dairy +85% · Protein +82% across all festivals |
| Promo rate vs discount depth scatter | Struggling stores: high promo rate + deep discounts → poor results. Star: low promo rate + shallow discounts → better margins |

**Key finding:** Republic Day is the most underestimated demand event — nearly every category spikes above 100%. Struggling stores run 24.2% promo rate vs 6.9% for Star — discounting more but earning less margin.

---

## 🔢 Key DAX Measures

| Measure | Purpose |
|---|---|
| `Retention %` | % of month-0 cohort still active each month |
| `Cohort Month` | Assigns each customer their first order month |
| `Month Offset` | Months elapsed since first order |
| `Days Until Stockout` | Current stock ÷ 30-day sales velocity |
| `Risk Tier` | STOCKOUT / CRITICAL / HIGH RISK / REORDER / REVIEW / OK |
| `Current Stock` | Latest stock snapshot per store-product |
| `Is Latest Date` | Flags most recent inventory row per store-product |
| `On-Time Rate Normal` | On-time % excluding rainy days |
| `On-Time Rate Rainy` | On-time % on rainy days only |
| `Avg Mins Normal` | Average delivery minutes on dry days |
| `Avg Mins Rainy` | Average delivery minutes on rainy days |
| `Gross Margin % by Tier` | (Revenue - COGS) / Revenue × 100 |

---

## 📈 Key Findings Summary

| Page | Key Finding | Business Impact |
|---|---|---|
| Overview | Struggling stores: 12% cancellation vs 2% Star | Fix ops before scaling |
| Store Performance | 12.5x revenue gap Star vs Struggling | Not location — ops quality |
| Profit & Margin | Struggling margin declining 29% → 25% | Urgent intervention needed |
| Inventory | ₹17.3L lost to stockouts | Perishables need daily replenishment |
| Customer | All channels lose 40–50% by month 3 | First 30 days is critical window |
| Delivery Ops | Rain collapses on-time from 99% to 4% | Weather-adjusted SLA needed |
| External | Republic Day biggest spike — most underplanned | Stock 5–7 days before |

---

## 🛠️ Tools & Skills Demonstrated

- **Power BI Desktop** — 7-page interactive dashboard
- **DAX** — calculated columns, measures, time intelligence
- **Data modelling** — star schema, relationships, cross-filtering
- **Conditional formatting** — heatmaps, traffic light tables
- **Visual design** — consistent colour system, tier-based colour coding
- **Business storytelling** — each page answers one business question

---

## ▶️ How to Open

**Prerequisites:** Power BI Desktop (free download from Microsoft)

```
1. Download the .pbix file
2. Open in Power BI Desktop
3. Use the navigation buttons at the top to switch pages
4. Use the filter panel (left slide-out) to filter by:
   - Tier (Star / Good / Average / Struggling)
   - Channel (app / web)
   - Zone (A / B / C / D)
   - Order status (delivered / cancelled)
```

---

## 👤 About

**Srividya Achar** — transitioning into data analytics.
This dashboard is part of a complete end-to-end analytics portfolio built on simulated quick-commerce data.

**LinkedIn:** linkedin.com/in/srividya-achar
**Email:** SrividyaAchar@outlook.com
🔗 **SQL Project:** [SwiftBasket SQL Analytics →](../swiftbasket-sql-portfolio)

---
*Power BI Dashboard · DAX · SQL Server 2022 · Quick Commerce Analytics*
