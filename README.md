# 🚲 Retail Sales & Inventory Intelligence System

> **End-to-end retail analytics pipeline built using Excel, PostgreSQL, and Power BI**
> 
> Labmentix Data Analytics Internship | Raju Kumar S | May 2026

---

## 📌 Problem Statement

A bicycle retail company operating **3 stores** across New York, California, and Texas had no systematic way to monitor sales performance, track inventory gaps, evaluate staff output, or identify shipment failures. Management relied on manual reporting with no real-time visibility into operations.

**Key questions this project answers:**
- Which stores, brands, and categories drive the most revenue?
- Where is inventory critically low or out of stock?
- How many orders are delayed and who is responsible?
- Who are the top customers and where are they concentrated?
- How does staff performance vary across stores?

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| Microsoft Excel / WPS | Data cleaning, preprocessing, EDA |
| PostgreSQL (pgAdmin) | Relational database design, SQL analysis |
| Power BI Desktop | Interactive dashboard and DAX measures |

---

## 📂 Dataset

- **Source:** BikeStores relational dataset
- **Size:** 5,000+ transactions across 3 years (2016–2018)
- **Format:** 9 CSV files → imported into PostgreSQL

### Schema

```
Sales Domain          Production Domain
─────────────         ─────────────────
orders                products
order_items           brands
customers             categories
staffs                stocks
stores
```

### Table Row Counts

| Table | Rows |
|---|---|
| orders | 1,615 |
| order_items | 4,722 |
| customers | 1,445 |
| products | 321 |
| stocks | 939 |
| staffs | 10 |
| stores | 3 |
| brands | 9 |
| categories | 7 |

---

## 🔄 Project Phases

### Phase 1 — Excel: Data Cleaning & EDA

**Cleaning steps:**
- Loaded all 9 CSVs into a single workbook as separate sheets
- Added `order_status_label` column mapping numeric codes → Pending / Processing / Rejected / Completed
- Added `shipment_status` column → Shipped / Not Shipped
- Added `revenue` column in order_items → `quantity × list_price × (1 - discount)`
- Verified zero duplicates and zero foreign key violations across all 9 tables
- Handled nulls: `customers.phone` (1,267 nulls — non-essential, retained)

**EDA Pivot Tables:**

| Pivot Table | Key Finding |
|---|---|
| Orders by Store | Baldwin Bikes handles 68% of all orders (1,093 of 1,615) |
| Order Status | 89.5% completion rate — 45 rejected orders flagged |
| Orders by Year | 2016: 635, 2017: 688 (peak), 2018: 292 (partial year) |

---

### Phase 2 — PostgreSQL: Database & SQL Analysis

**Database setup:**
- Created `retail_sales` database with 9 tables
- Enforced foreign key constraints across all relationships
- Imported data using `COPY` command with NULL handling

**SQL Views created:**

| View | Purpose |
|---|---|
| `vw_store_revenue` | Aggregated revenue and order count per store |
| `vw_staff_performance` | Revenue and order count per staff with store reference |
| `vw_product_sales` | Units sold and revenue per product with brand and category |
| `vw_order_details` | Full order view with customer, staff, delivery status and revenue |

**Key SQL Findings:**

| Analysis | Finding |
|---|---|
| Revenue by Store | Baldwin Bikes: $5.2M (67%), Santa Cruz: $1.6M, Rowlett: $867K |
| Top Brand | Trek: $4.6M revenue — Electra: highest volume at 2,612 units |
| Top Category | Mountain Bikes: $2.72M — Road Bikes: $1.67M |
| Staff Performance | Marcelene Boyer: $2.62M top — Layla Terrell: $403K lowest |
| Delayed Shipments | 628 of 1,615 orders delayed or not shipped — 39% of total |
| Stock Alerts | 15 out-of-stock situations — Baldwin Bikes most affected |
| Customer Geography | NY: 1,019 customers ($5.2M) — CA: 284 — TX: 142 |

---

### Phase 3 — Power BI: Interactive Dashboard

**3-page dashboard connected to PostgreSQL views**

#### Page 1 — Sales Overview
- 5 KPI cards: Total Revenue, Total Orders, Total Customers, Avg Order Value, Delayed Order %
- Revenue by Store (bar chart)
- Revenue by Category (bar chart)
- Staff Performance by Revenue (bar chart)
- Monthly Revenue Trend (line chart)
- Revenue by State (map visual)
- Year and Store Name slicers

#### Page 2 — Inventory & Orders
- Delayed Shipments table (filtered to delayed orders only)
- Total Stock by Store (bar chart)
- Top Customers by Revenue (table)

#### Page 3 — Customer & Staff
- Revenue by State (bar chart)
- Top 10 Customers by Revenue (bar chart)
- Staff Orders vs Revenue (scatter chart)
- Orders by Status (donut chart)
- Filter by State and Filter by Staff slicers

**DAX Measures:**
```
Total Revenue = SUM(vw_order_details[order_revenue])

Avg Order Value = DIVIDE([Total Revenue], DISTINCTCOUNT(vw_order_details[order_id]))

Delayed Order % = 
DIVIDE(
    CALCULATE(
        COUNTROWS('public vw_order_details'),
        'public vw_order_details'[delivery_status] IN {"Delayed", "Not Shipped"}
    ),
    COUNTROWS('public vw_order_details')
) * 100
```

---

## 📊 Key Business Insights

### 1. Revenue Concentration Risk
Baldwin Bikes generates **67% of total revenue** ($5.2M of $7.69M). Heavy dependence on one store is a critical business risk — any disruption at this store severely impacts overall performance.

### 2. Shipment Performance Issue
**39% of orders** (628 of 1,615) are either delayed or not shipped. This is a significant operational failure directly impacting customer satisfaction and repeat business.

### 3. Inventory Management Gap
Baldwin Bikes has **15 out-of-stock situations** despite being the highest revenue store. Road Bikes and Electric Bikes are most critically affected — high-value categories where stockouts directly translate to lost sales.

### 4. Brand Strategy
- **Trek** dominates revenue at $4.6M (premium segment)
- **Electra** dominates volume at 2,612 units (value segment)
- Two distinct customer segments require different inventory and marketing strategies

### 5. Geographic Concentration
**New York accounts for 70% of customers and 67% of revenue.** California and Texas are significantly underserved — growth opportunity exists given existing store presence.

---

## 📈 KPI Summary

| KPI | Value |
|---|---|
| Total Revenue | $7.69M |
| Total Orders | 1,615 |
| Total Customers | 1,445 |
| Avg Order Value | $4.76K |
| Delayed Order % | 38.89% |
| Top Store | Baldwin Bikes — $5.2M |
| Top Category | Mountain Bikes — $2.72M |
| Top Brand | Trek — $4.6M |
| Top Customer | Sharyn Hopkins — $34.8K |

---

## 📁 Repository Structure

```
📦 Retail-Sales-Inventory-Intelligence-System
 ┣ 📄 README.md
 ┣ 📊 Retail_Sales_Mastersheet.xlsx     ← Cleaned Excel workbook with EDA
 ┣ 🗄️ retail_sales_queries.sql          ← SQL schema, queries and views
 ┗ 📝 Final_Report_Raju_Kumar_S.docx    ← Full project report
```

---

## 🚀 How to Reproduce

**Step 1 — Excel**
- Open `Retail_Sales_Mastersheet.xlsx`
- Review 9 sheets, pivot tables, and added columns

**Step 2 — PostgreSQL**
- Create a database called `retail_sales`
- Run `retail_sales_queries.sql` in pgAdmin Query Tool
- All tables, data imports, queries and views will be created

**Step 3 — Power BI**
- Open Power BI Desktop
- Connect to PostgreSQL: `localhost / retail_sales`
- Load the 4 views and relevant tables
- Build dashboard using the views

---

## 💡 What I Learned

- Designing and querying a normalized relational database with foreign key constraints
- Writing complex multi-table SQL joins, CASE statements, and reusable views
- Connecting Power BI directly to PostgreSQL and building DAX measures
- Translating raw data findings into clear business insights and recommendations
- Structuring an end-to-end analytics project from raw CSV to interactive dashboard

---

## 👤 Author

**Raju Kumar S**  
Data Analytics Intern — Labmentix  
May 2026