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

- Exploratory Data Analysis (EDA)
- Data Quality Assessment
- SQL Validation
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
| Coverage | 2016–2022 |
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

- Approximately 70% of IFR variables contain missing values.
- Operational KPIs are calculated using **Total Movements** instead of IFR variables.
- The dataset contains 333 airport names but represents 332 unique airports.
- Year 2022 includes data from January to May only.

---

# Data Architecture

The analytical model follows a **Star Schema** optimized for Power BI performance.

### Fact Table

- Fact_AirTraffic

### Dimensions

- Dim_Date
- Dim_Airport
- Dim_Country

*(Star Schema image)*

---

# SQL Workflow

SQL Server is used during the initial validation stage to verify the integrity of the source dataset before loading it into Power BI.

Included scripts:

- Dataset Import
- Exploratory Data Analysis
- Data Quality Assessment
- Star Schema Design
- Business KPI Queries

---

# Power Query Workflow

Power Query is responsible for preparing the analytical model.

Main transformations include:

- Data type validation
- Duplicate detection
- Null value assessment
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
- Opportunity Score
- Strategic Priority

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

- The five largest countries represent **55.6%** of European air traffic.
- Approximately **25% of airports generate 80%** of total traffic.
- Air traffic decreased **56.8%** during 2020.
- Traffic recovered to **77.1%** of 2019 levels by May 2022.
- Airport growth dynamics differ significantly from traffic volume alone.

---

# Business Recommendations

## Short Term

Prioritize commercial initiatives in airports with the highest Congestion Risk Index.

## Medium Term

Monitor high-growth airports separately from mature hub airports.

## Long Term

Use recovery patterns and sustained growth as decision criteria for strategic partnerships.

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
- Airport capacity is estimated indirectly through traffic growth.
- 2022 is a partial year.
- The Congestion Risk Index is a directional indicator rather than a certified operational metric.

---

# Author

**Gerónimo Daguerre**

Business Intelligence • Data Analytics • Airport Operations • Customer Experience • Project Management

---

# License

This project was developed for educational purposes and professional portfolio use using a publicly available Kaggle dataset.
