# 📊 SwiftBasket Quick Commerce — Power BI Dashboard

![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?logo=powerbi)
![DAX](https://img.shields.io/badge/DAX-Measures%20%26%20Columns-blue)
![Pages](https://img.shields.io/badge/Dashboard-7%20Pages-purple)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Domain](https://img.shields.io/badge/Domain-Quick%20Commerce-orange)

---

## 📌 Project Overview

**SwiftBasket** is a simulated Bengaluru-based hyperlocal grocery delivery business — similar to Blinkit, Zepto, or Swiggy Instamart. This 7-page interactive Power BI dashboard is the visual analytics layer of the project, built directly on cleaned SQL data to turn query results into actionable business intelligence.

The dashboard covers **40 dark stores**, **23,119 orders**, **5,663 customers**, and **₹1.07 Cr revenue** across a 4-month period (Dec 2025 – Mar 2026).

> 🔗 **SQL Project:** [SwiftBasket SQL Analytics →](../swiftbasket-sql-portfolio)

---

## 🗂️ Dashboard Navigation

The dashboard includes a branded navigation panel with cross-page slicers:

| Filter | Options |
|---|---|
| **Tier** | Star · Good · Average · Struggling |
| **Channel** | App · Web |
| **Zone** | Zone A · Zone B · Zone C · Zone D |
| **Order Status** | Delivered · Cancelled |

All slicers filter every visual across every page simultaneously.

---

## 📋 Page-by-Page Insights

---

### Page 1 — Overview

> **Business question:** How is the overall business performing?

**Visuals:**
- 5 KPI cards — Revenue · Gross Profit · Total Orders · Cancellation Rate · Stockout Leakage
- Effective Revenue 7-day rolling avg (Star+Good vs Average+Struggling)
- Revenue share by tier donut chart
- Orders by hour of day bar chart
- Orders by day of week bar chart
- Order status funnel

**Key Insights:**

- **₹1.07 Cr revenue with a -13.1% decline vs prior period** — the business is shrinking, not growing. This decline warrants urgent investigation across all pages.
- **Good tier generates 39.45% of revenue despite not being the top tier** — with 10 stores, Good tier is the backbone of the business. Star stores (3 stores) contribute 23.43% — impressive per-store but limited scale.
- **Struggling stores generate only 8.78% of revenue** despite being the largest group — these stores are a drag on overall performance and need operational intervention, not just more marketing.
- **Peak demand is 8–9pm with a morning spike at 8am** — staffing, rider availability, and inventory readiness should be optimised around these two windows, not spread evenly across the day.
- **Saturday and Sunday are 35–40% above weekday volumes** — weekend stock pre-positioning is critical to avoid stockouts during the highest demand days.
- **₹17.3L stockout leakage at 4.8% stockout rate** — nearly ₹1 in every ₹20 of potential revenue is being lost because products are unavailable when customers want them.
- **Struggling stores: 13% cancellation vs overall 5.5%** — the cancellation rate for struggling stores is more than double the average, meaning customers are placing orders that cannot be fulfilled.

---

### Page 2 — Store Performance

> **Business question:** Which stores are winning and which are struggling — and why?

**Visuals:**
- 4 KPI cards — avg revenue per store by tier
- All 40 stores ranked by delivered revenue (horizontal bar)
- Order fulfilment rate by tier (bar chart)
- Store scorecard table — all 40 stores with revenue, margin, fulfilment, stockout rate

**Key Insights:**

- **Star stores avg ₹8.3L vs Struggling ₹66.8K — a 12.5x revenue gap** — this is not a small performance difference. A single Star store generates as much revenue as 12 Struggling stores combined.
- **Top 3 stores are all Zone A locations in Koramangala, HSR Layout, and Indiranagar** — these are high-density, high-income central Bengaluru areas. But the gap is not purely geographic — Good tier stores in the same localities perform significantly lower.
- **Fulfilment rate drops from 97% (Star) to 82% (Struggling)** — a 15 percentage point gap in fulfilment means 1 in 6 Struggling store orders cannot be completed. This directly explains the higher cancellation rates seen on the Overview page.
- **Average tier stores cluster around ₹1.8L–₹2.9L** with consistent 33–34% gross margins — these stores are stable but not growing. They represent the largest untapped opportunity: small operational improvements could move several into the Good tier.
- **Struggling stores show stockout rates of 10–12%** in the scorecard — nearly three times the Star store rate of ~0.3%. Inventory management, not customer demand, is limiting these stores.

---

### Page 3 — Profit & Margin

> **Business question:** Where is margin being made and where is it being eroded?

**Visuals:**
- 4 KPI cards — avg revenue per store by tier
- Effective Revenue and Gross Profit by tier (clustered bar)
- Gross Margin % by tier (bar chart)
- Gross Margin % by category (horizontal bar)
- Gross Margin % trend over time by tier (line chart)

**Key Insights:**

- **Star tier achieves 43.9% gross margin vs Struggling at 27.4%** — a 16.5 percentage point gap. The same products, same pricing, but dramatically different profitability. The difference lies in discount depth, promo frequency, and order fulfilment efficiency.
- **Good tier generates the highest absolute gross profit (₹1.6M)** despite Star having better per-store margins — because Good tier has more stores and more volume. Growing the Good tier is the highest-impact margin lever.
- **Gross margin is almost flat across all categories (37–38%)** — Personal Care leads at 38.3%, Protein trails at 37.0%. This 1.3 percentage point spread suggests pricing is formulaic across categories rather than strategically differentiated. There is an opportunity to increase margins on high-demand, low-substitution categories.
- **Struggling tier margin is actively declining — from 29% in Dec 2025 to 25% by Mar 2026** — this is the most alarming finding on this page. It is not just that Struggling stores earn less; they are earning progressively less over time. If unchecked, these stores will become loss-making within months.
- **Star and Good tier margins are stable and flat over 4 months** — confirming that the decline is isolated to Struggling stores, not a business-wide pricing or cost issue.

---

### Page 4 — Inventory

> **Business question:** Which products are at risk of stocking out and how much revenue is being lost?

**Visuals:**
- 5 KPI cards — Revenue · Gross Profit · Total Orders · Cancellation Rate · Stockout Leakage
- Inventory Risk table — store × product level with Risk Tier colour coding
- Lost Revenue by product (horizontal bar)
- Near Stockouts by tier label (bar chart)

**Key Insights:**

- **₹17.3L lost to stockouts at 4.8% stockout rate** — this is revenue that customers tried to spend but could not because the product was unavailable. It is recoverable with better inventory management.
- **Chicken 1kg accounts for ₹1.63L of lost revenue — the single largest stockout product** — as a perishable, high-velocity protein item, Chicken requires daily replenishment. Any gap in supply chain creates immediate lost sales.
- **Top 7 stockout products account for the majority of leakage:** Chicken 1kg ₹163K · Breakfast Cereal ₹108K · Ice Cream 500ml ₹91K · Detergent 1kg ₹74K · Cooking Oil 1L ₹72K · Shampoo 200ml ₹68K · Frozen Peas 500g ₹68K.
- **Struggling stores have 8,300 near-stockout events vs near zero for Star** — this is systemic, not occasional. The inventory risk table shows Struggling store products consistently sitting below reorder point, meaning replenishment cycles are too infrequent.
- **"REVIEW (not selling)" classification identifies products with stock but no recent sales** — these are equally problematic in the other direction: capital is tied up in inventory that customers are not buying. These SKUs need either promotion, repricing, or delisting.
- **REORDER NEEDED dominates the risk table** — most stores are not in active stockout but are consistently operating below safe stock levels, meaning any demand spike (such as a festival or rainy day) will immediately cause stockouts.

---

### Page 5 — Customer

> **Business question:** Who are our customers, how were they acquired, and are we retaining them?

**Visuals:**
- 4 KPI cards — Total Customers · Repeat Rate · Avg Orders per Customer · Estimated LTV 12
- Customer Retention heatmap matrix (acquisition channel × month)
- Top acquisition channels bar chart
- Customers by age group bar chart

**Key Insights:**

- **86.5% repeat rate and 4.08 avg orders in 4 months** — these are strong engagement numbers. The majority of customers who order once continue to order, suggesting the product experience is satisfactory.
- **Estimated 12-month LTV of ₹5,642** — this is the lifetime value extrapolated from 4-month data. Knowing this number allows the business to set a rational customer acquisition cost ceiling: spending more than ₹5,642 to acquire a customer destroys value.
- **Every acquisition channel loses 40–60% of customers by month 3** — despite the strong overall repeat rate, the retention heatmap shows a consistent and steep drop from Month 0 (100%) to Month 1 (57–60%) to Month 3 (36–40%). The first 30 days after acquisition is the critical intervention window.
- **Paid App Install has the best month-1 retention at 60%** — customers acquired through the app are slightly more sticky than those from other channels. This suggests app users have higher intent and engagement from the start.
- **Influencer channel has the worst month-3 retention at 36%** — influencer-acquired customers are least loyal long-term. Despite decent month-1 numbers, they drop off fastest, suggesting they were attracted by a specific campaign rather than genuine product need.
- **Organic + Referral = 52% of revenue** — more than half of all revenue comes from the two lowest-cost acquisition channels. This is a very healthy signal — the business is not dependent on paid marketing to sustain itself.
- **25–34 age group = 42% of customers — the core audience** — all product, communication, and retention strategies should be optimised for this cohort first. The 35–44 segment at 25% is the natural expansion target.

---

### Page 6 — Delivery Ops

> **Business question:** Are we delivering on time, and what is causing delays?

**Visuals:**
- 4 KPI cards — On-Time Rate · Avg Actual Delivery · Avg Pick & Pack · Avg Distance KM
- Actual vs promised delivery by tier (clustered bar)
- On-time rate by store (horizontal bar)
- On-Time Delivery Rate: Normal vs Rainy Days (clustered bar)
- Avg Delivery Time: Normal vs Rainy Days (clustered bar)

**Key Insights:**

- **Overall on-time rate of 34.5% against an industry benchmark of 85%+** — the business is operating at less than half the industry standard for delivery SLA compliance. This is a critical operational gap that directly impacts customer satisfaction and repeat rate.
- **Struggling stores promise 50 minutes but deliver in 68 minutes on average — an 18-minute gap** — Star stores promise 30 minutes and deliver in 33 minutes — a 3-minute gap. Better-run stores set more realistic promises AND deliver faster.
- **Best-performing store (Indiranagar Zone C) achieves only 38.6% on-time rate** — even the top store is far below industry standard. This suggests the problem is systemic — likely in how promised delivery time is calculated — rather than individual store or rider performance.
- **Rain drops on-time rate from 99% to just 2–6% across ALL tiers** — this is the most striking finding on this page. A 95 percentage point collapse means rain essentially stops on-time delivery entirely. This is an ops failure, not a weather impossibility.
- **Distance is NOT the cause — average delivery distance is only 2.85km** — all deliveries are hyperlocal. The rainy day collapse is caused by pick-pack handoff delays and rider slowdowns, not by long routes. The SLA policy needs to account for weather conditions.
- **Rain adds 27–39 minutes to delivery time across all tiers** — Star stores go from 15 to 42 minutes, Struggling stores from 42 to 81 minutes. A weather-adjusted SLA — automatically extending promised time when `is_rainy = 1` — would immediately improve the on-time metric without changing actual delivery speed.

---

### Page 7 — External Factors

> **Business question:** How do festivals, weather, and promotions affect demand and performance?

**Visuals:**
- 4 KPI cards — Festival Demand Lift · Rainy Day Order Drop · Star Promo Rate · Struggling Promo Rate
- Festival Demand Spike heatmap (12 categories × 7 festivals)
- Festival lift by category (horizontal bar)
- Promo rate vs discount depth scatter plot

**Key Insights:**

- **Festival demand is +78% above normal days on average** — across all 7 festivals tracked, orders nearly double during the pre-festival window. This is predictable and plannable — yet inventory data shows stockouts during these same periods, suggesting planning is not aligned with known demand patterns.
- **Republic Day is the most intense demand event** — nearly every category spikes above 100%: Protein +137%, Dairy +133%, Personal Care +129%, Snacks +127%. It is the most underestimated festival in the calendar because it is not traditionally thought of as a shopping festival.
- **Frozen category is the most consistent festival performer** — it ranks in the top 2 spike categories across Christmas, Holi, Makar Sankranti, Valentine's Day, and Ugadi. Despite low revenue share, it over-indexes on demand change at every festival. Pre-festival Frozen stock builds should be non-negotiable.
- **Ugadi and Makar Sankranti spike hardest overall** — the heatmap shows the darkest green concentrated in these two festivals. South Indian and pan-Indian festival calendars need to be built into the replenishment model at least 5–7 days in advance.
- **Rainy days cause a -23.3% drop in orders AND delivery is 127.8% longer** — rain simultaneously reduces demand and degrades supply. The operational impact compounds: fewer orders means less revenue, and slower delivery means lower customer satisfaction from the orders that do come in.
- **Struggling stores run a 24.2% promo rate with 35% avg discount vs Star at 6.9% with 10% discount** — Struggling stores are discounting heavily and frequently but still underperforming. The promo scatter confirms this: more promotions and deeper discounts do not translate to better results when the underlying ops are broken. Star stores run fewer, shallower promos but generate 12.5x more revenue per store.

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
| `On-Time Rate Normal` | On-time % on non-rainy days |
| `On-Time Rate Rainy` | On-time % on rainy days only |
| `Avg Mins Normal` | Average delivery minutes on dry days |
| `Avg Mins Rainy` | Average delivery minutes on rainy days |
| `Gross Margin % by Tier` | (Revenue − COGS) ÷ Revenue × 100 |

---

## 📈 Key Findings Summary

| Page | Finding | Impact |
|---|---|---|
| Overview | Revenue down 13.1% vs prior period | Urgent business health concern |
| Overview | ₹17.3L lost to stockouts | Recoverable with better inventory planning |
| Store Performance | 12.5x revenue gap Star vs Struggling | Ops quality gap not location gap |
| Profit & Margin | Struggling margin declining 29% → 25% | Stores becoming loss-making |
| Inventory | Chicken 1kg = ₹163K lost revenue | Daily replenishment required |
| Customer | All channels lose 40–60% by month 3 | First 30 days is critical retention window |
| Delivery Ops | Rain drops on-time from 99% to 4% | Weather-adjusted SLA needed immediately |
| External | Republic Day most underplanned event | Pre-stock all categories 7 days before |

---

## 🛠️ Tools Used

- **Power BI Desktop** — data modelling, DAX, interactive visuals
- **DAX** — calculated columns, measures, time intelligence, conditional logic
- **SQL Server 2022** — data source (clean.* schema)
- **Star schema data model** — 5 fact tables, 4 dimension tables, 1 date table

---

## ▶️ How to Open

1. Download Power BI Desktop (free — [microsoft.com/powerbi](https://powerbi.microsoft.com))
2. Download the `.pbix` file from this repository
3. Open in Power BI Desktop
4. Use the navigation buttons at the top to move between pages
5. Use the filter panel (click the grid icon top left) to filter by Tier, Channel, Zone, or Order Status

---

## 👤 About

**Srividya Achar** — transitioning into data analytics from 8 years in IT operations at TCS and Wipro.

📧 SrividyaAchar@outlook.com
🔗 [LinkedIn](https://linkedin.com/in/srividya-achar)
🔗 [SQL Project](../swiftbasket-sql-portfolio)
🔗 [Portfolio](your-portfolio-link)

---
*Power BI · DAX · SQL Server · Quick Commerce Analytics · Bengaluru*
