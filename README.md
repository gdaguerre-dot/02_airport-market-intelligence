# Airport market intelligence

**Business Intelligence case study: validating and redesigning a commercial prioritization model**

Este proyecto desarrolla un modelo de **Business Intelligence** para priorizar mercados aeroportuarios europeos con mayor potencial comercial mediante **SQL Server, Power Query, DAX y Power BI**.

El principal aporte del proyecto no fue la construcción del dashboard, sino la **validación metodológica del modelo analítico** que generaba el ranking de prioridades.

A partir de una auditoría completa del dataset y del indicador original, el proyecto detectó distorsiones estadísticas, revisó supuestos de comparabilidad histórica y rediseñó el **Congestion Opportunity Score (COS)** para construir un modelo de decisión reproducible y orientado a expansión comercial.

---

# Executive summary

- **688.099 registros analizados**
- **332 aeropuertos**
- **42 países europeos**
- **Período:** 2016–2022
- **Granularidad:** aeropuerto × día

El proyecto evolucionó desde un dashboard descriptivo hacia un **framework analítico documentado**, incorporando una capa de validación SQL, modelado dimensional, criterios explícitos de elegibilidad y una arquitectura DAX alineada con la lógica de negocio.

---

# Business problem

¿Cómo priorizar los mercados aeroportuarios europeos que combinan simultáneamente **escala operativa y crecimiento sostenible**, evitando que el ranking quede distorsionado por anomalías estructurales, series históricas incompletas o efectos de base?

El proyecto responde esa pregunta mediante el diseño y validación de un indicador compuesto de priorización comercial.

---

# Key contribution

El proyecto demuestra cómo un indicador técnicamente correcto puede producir **decisiones comerciales incorrectas** si no se validan sus supuestos estadísticos y su comparabilidad histórica.

El resultado final es un **modelo de priorización comercial robusto, interpretable y reproducible**.

---

# Analytical workflow

El desarrollo siguió un proceso analítico estructurado:

1. Importación y validación del dataset.
2. Análisis exploratorio (EDA).
3. Evaluación de calidad de datos.
4. Detección de anomalías.
5. Modelado dimensional.
6. Transformación mediante Power Query.
7. Desarrollo de medidas DAX.
8. Construcción del dashboard.
9. Validación metodológica del COS.
10. Documentación y recomendaciones estratégicas.

---

# Technical architecture

El proyecto implementa una arquitectura analítica reproducible para preservar trazabilidad y gobernanza de datos.

```text
Flights.csv
      ↓
SQL Server (Raw Layer)
      ↓
SQL Data Quality Validation
      ↓
Power Query (ETL)
      ↓
Star Schema
      ↓
DAX Measures
      ↓
Power BI Dashboard
      ↓
Commercial Prioritization
```

---

# Dimensional model

El dashboard fue construido sobre un **esquema estrella (Star Schema)**.

**Tabla de hechos**

- Fact_TraficoAereo

**Dimensiones**

- Dim_Fecha
- Dim_Aeropuerto
- Dim_Pais

Este diseño permite optimizar rendimiento, inteligencia temporal, segmentación y escalabilidad del modelo.

---

# Congestion Opportunity Score (COS)

El principal aporte analítico del proyecto es el desarrollo del **Congestion Opportunity Score (COS)**.

El indicador combina dos dimensiones estratégicas:

- **Market Share Normalized**
- **Growth Score**

**COS = 0.50 × Market Share Normalized + 0.50 × Growth Score**

La versión final del modelo reemplaza el enfoque inicial basado en CAGR por un crecimiento interanual comparable (2018–2019), incorporando criterios explícitos de elegibilidad y exclusión de anomalías estructurales.

---

# Main methodological decisions

- Validación del grano real del dataset (aeropuerto × día).
- Corrección de inconsistencias de nomenclatura (LLBG).
- Utilización de movimientos totales como métrica principal.
- Exclusión de LTFM del componente de crecimiento por cambio estructural.
- Comparación de períodos homogéneos para Recovery Rate.
- Normalización de componentes del COS.
- Implementación de criterios de elegibilidad directamente en DAX.

---

# Results

- **87.056.538 movimientos aéreos analizados**
- **55,6% del tráfico europeo concentrado en cinco países**
- **84 de 332 aeropuertos generan aproximadamente el 80% del tráfico**
- **Caída de tráfico 2020 vs. 2019:** -56,8%
- **Recuperación Ene–May 2022 vs. Ene–May 2019:** 76,6%

Tras el rediseño metodológico, **Frankfurt, Milán-Malpensa y Antalya** emergen como los mercados con mayor potencial estratégico según el COS.

---

# Dashboard pages

El dashboard ejecutivo está organizado en cinco páginas:

- Executive Overview
- Country Analysis
- Airport Analysis
- Air Traffic Evolution
- Strategic Opportunities

Cada página responde una pregunta específica de negocio y forma parte de una narrativa analítica progresiva.

---

# Repository structure

```text
airport-market-intelligence/
│
├── README.md
├── Airport-Market-Intelligence-BI-Case-Study.pdf
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
│   ├── dashboard_overview.png
│   ├── dashboard_country_analysis.png
│   ├── dashboard_airport_analysis.png
│   ├── dashboard_air_traffic_evolution.png
│   └── dashboard_strategic_opportunities.png
│
└── data/
```

---

# Full case study

El documento completo del proyecto se encuentra en:

**Airport-Market-Intelligence-BI-Case-Study.pdf**

---

# Technologies

**SQL Server · Power Query (M) · DAX · Power BI · Star Schema · Business Intelligence · Data Analytics · Data Quality · Data Storytelling**

---

# Limitations

El proyecto utiliza información histórica de tráfico aéreo y no incorpora:

- demoras,
- cancelaciones,
- capacidad aeroportuaria,
- conectividad de rutas,
- participación de aerolíneas,
- variables macroeconómicas.

El **Congestion Opportunity Score (COS)** constituye un indicador de priorización estratégica y no una medición operativa certificada de congestión aeroportuaria.

---

# Author

**Gerónimo Daguerre**

Business Intelligence · Data Analytics · SQL · Power BI · DAX

GitHub: https://github.com/gdaguerre-dot

---

# License

Este proyecto fue desarrollado con fines educativos y de portfolio profesional utilizando un conjunto de datos de acceso público disponible en Kaggle.
