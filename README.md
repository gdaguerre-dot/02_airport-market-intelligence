# Airport Market Intelligence
## Business Intelligence for Airport Market Prioritization

**Power BI · SQL Server · Power Query (M) · DAX · Data Modeling · Business Intelligence · Storytelling · Aviation Industry**

---

## Project Overview

Airport Market Intelligence is a Business Intelligence project that analyzes more than **688,000 European air traffic records (2016–2022)** to identify airport markets with the highest strategic value for **VueloJusto**, a company specialized in passenger compensation services.

Rather than focusing only on traffic volume, the project introduces a business-oriented analytical approach based on airport market concentration, traffic evolution, post-pandemic recovery and a custom **Congestion Risk Index**, developed entirely in Power BI using Power Query and DAX.

The objective is to transform operational air traffic data into actionable business insights that support commercial decision-making.

---

# Business Problem

VueloJusto operates in the passenger compensation industry, where commercial resources are limited and must be allocated strategically.

Although flight delays generate business opportunities, the available dataset does not include delay or compensation claim information.

Therefore, this project estimates airport congestion risk using air traffic volume and sustained traffic growth as analytical proxies.

### Business Question

> **Which European airport markets present the highest structural congestion risk and therefore represent the greatest commercial opportunity for VueloJusto?**

---

# Analytical Approach

The project follows a complete Business Intelligence workflow:

- Exploratory Data Analysis (EDA), including duplicate detection, null-value assessment and outlier review
- SQL Server validation (Raw Layer)
- Dimensional Data Modeling (Star Schema)
- Power Query (M) Data Preparation
- DAX Measures and KPIs
- Executive Dashboard Design
- Data Storytelling and Business Recommendations

---

# Dataset

| Metric | Value |
|---------|-------|
| Source | Kaggle – European Flights Dataset |
| Records | 688,099 |
| Countries | 42 |
| Airports | 332 |
| Coverage | 2016-01-01 to 2022-05-31 (2022 is a partial year: January–May) |
| Granularity | Airport-Day |

### Main Variables

- Country
- Airport
- Flight Date
- Arrivals
- Departures
- Total Movements
- IFR Operations

### Data Quality Notes

- Approximately 70% of IFR variables contain missing values; operational KPIs are calculated using **Total Movements** instead.
- The dataset contains 333 airport names but represents 332 unique airports (one airport listed under two name variants).
- Year 2022 includes data from January to May only — year-over-year comparisons involving 2022 use matching partial periods (Jan-May vs. Jan-May), not full calendar years.
- Istanbul Airport (LTFM) is excluded from sustained-growth calculations: its 2018→2019 figures reflect the airport's opening (replacing Istanbul-Atatürk), not organic demand growth, and would distort the Congestion Risk Index if included.

---

# Data Architecture

The analytical model follows a **Star Schema** optimized for Power BI performance, built on top of a SQL Server Raw Layer that preserves the original dataset before any transformation.

```
Flights.csv → SQL Server (Raw Layer) → EDA & Validation → Power Query (ETL) → Star Schema → Power BI
```

### Fact Table

- Fact_AirTraffic

### Dimensions

- Dim_Date
- Dim_Airport
- Dim_Country

*(Star Schema image)*

---

# SQL Workflow

SQL Server hosts the Raw Layer of the project (database `AirportMarketDB`) and is used to validate and explore the source dataset before it is transformed and loaded into Power BI — not merely as a one-off validation step, but as the persistent, queryable base layer that every later stage references.

Included scripts:

- `01_import_dataset.sql` — Dataset import and environment setup
- `02_exploratory_analysis.sql` — Exploratory Data Analysis
- `03_data_quality.sql` — Data Quality Assessment (duplicates, nulls, consistency, outliers)
- `04_star_schema.sql` — Star Schema design
- `05_business_queries.sql` — Business KPI queries (SQL baseline for the DAX measures)

---

# Power Query Workflow

Power Query is responsible for preparing the analytical model.

Main transformations include:

- Data type validation
- Duplicate detection (at the correct daily grain — airport + date)
- Null value assessment
- Airport name standardization
- Date dimension creation
- Airport dimension creation
- Country dimension creation
- Fact table preparation

---

# DAX Measures

### Volume KPIs

- Total Flights
- Average Flights
- Flights per Airport
- Flights per Country

### Market KPIs

- Market Share
- Top Airport Contribution
- Top Country Contribution
- Pareto Analysis

### Growth KPIs

- YoY Growth
- Annual Growth Rate
- Recovery Rate vs 2019
- Rolling Average

### Strategic KPIs

- Congestion Risk Index

*Opportunity Score and Strategic Priority are planned extensions of the Congestion Risk Index, not yet implemented — they will be added once validated against the current model.*

---

# Dashboard

The Power BI dashboard contains multiple analytical views:

- Executive Overview
- Country Analysis
- Airport Analysis
- Traffic Evolution
- Post-COVID Recovery
- Congestion Risk Assessment
- Strategic Recommendations

*(Dashboard screenshots)*

---

# Main Findings

- The five largest countries (Spain, Germany, UK, France, Italy) represent **55.6%** of European air traffic.
- **84 of 333 airports (25.2%)** generate 80% of total traffic (Pareto concentration).
- Air traffic decreased **56.8%** during 2020 vs. 2019.
- Traffic recovered to **77.1%** of 2019 levels — this compares the same Jan-May period in both years (2019 full year is not the denominator; full-year 2022 data is not yet available). 2021 alone reached 53.8% of full-year 2019.
- Airport growth dynamics differ significantly from traffic volume alone: none of the top 10 airports by sustained growth (led by Antalya and Milan-Malpensa) are among the top 10 by absolute volume — which is exactly the gap the Congestion Risk Index is designed to surface.

---

# Value for VueloJusto

- **Commercial anticipation:** identify high-congestion-risk markets before claim volume grows, enabling proactive (not reactive) partnership negotiations with travel agencies and airlines.
- **Differentiated risk management:** distinguishing already-saturated hubs from airports on a saturation trajectory allows the type of commercial engagement to be tailored to each profile.
- **Data storytelling for non-technical stakeholders:** the dashboard translates a complex analytical model (volume + growth + recovery) into a single index that is easy to communicate to a commercial or executive team.

---

# Business Recommendations

## Short Term

Prioritize commercial initiatives in airports with the highest Congestion Risk Index (currently led by Antalya and Milan-Malpensa).

## Medium Term

Monitor high-growth airports (medium volume, fast growth) separately from mature hub airports (high volume, slow growth) — each profile carries a different operational risk pattern.

## Long Term

Use recovery patterns and sustained growth as decision criteria for strategic partnerships (3-7 year horizon).

---

# Skills Demonstrated

- SQL Server
- Data Cleaning
- Exploratory Data Analysis
- Data Quality Assessment
- Star Schema Modeling
- Power Query (M)
- DAX
- Power BI
- KPI Design
- Business Intelligence
- Data Storytelling
- Business Analysis

---

# Repository Structure

```text
airport-market-intelligence/

│
├── README.md
│
├── pdf/
│   └── Airport_Market_Intelligence.pdf
│
├── powerbi/
│   └── Airport_Market_Intelligence.pbix
│
├── sql/
│   ├── 01_import_dataset.sql
│   ├── 02_exploratory_analysis.sql
│   ├── 03_data_quality.sql
│   ├── 04_star_schema.sql
│   └── 05_business_queries.sql
│
├── images/
│   ├── star_schema.png
│   ├── dashboard_overview.png
│   ├── dashboard_country_analysis.png
│   ├── dashboard_airport_analysis.png
│   └── dashboard_congestion_risk.png
│
└── LICENSE
```

---

# Limitations

- The dataset does not include flight delays or cancellations.
- Airport capacity is estimated indirectly through traffic growth — the Congestion Risk Index is a directional indicator, not a certified operational metric.
- 2022 is a partial year (January-May only).
- Istanbul Airport (LTFM) is excluded from growth calculations due to its 2019 opening artifact (see Data Quality Notes above).

---

# Author

**Gerónimo Daguerre**

Business Intelligence • Data Analytics • Airport Operations • Customer Experience • Project Management

[LinkedIn](https://www.linkedin.com/in/TU-USUARIO-AQUI) · [GitHub](https://github.com/TU-USUARIO-AQUI)

---

# License

This project was developed for educational purposes and professional portfolio use using a publicly available Kaggle dataset.
