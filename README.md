# Airport Market Intelligence
### Business Intelligence para la priorización estratégica de mercados aeroportuarios europeos
**Caso de negocio: VueloJusto**

Proyecto de Data Analytics desarrollado con SQL Server, Power Query, DAX y Power BI para identificar los aeropuertos europeos con mayor potencial comercial mediante un enfoque de Business Intelligence y análisis de datos.

---

## Resumen del proyecto

Este proyecto analiza **688.099 registros** de tráfico aéreo europeo (2016–2022) con el objetivo de identificar los mercados aeroportuarios que combinan una participación significativa en el mercado y un crecimiento sostenido del tráfico aéreo, proporcionando un criterio cuantitativo para priorizar oportunidades comerciales para **VueloJusto**, una plataforma especializada en la gestión de compensaciones por incidencias aéreas.

A diferencia de un análisis basado únicamente en volumen, el proyecto desarrolla un indicador compuesto denominado **Congestion Opportunity Score (COS)**, diseñado específicamente para integrar el tamaño actual del mercado con su potencial de crecimiento.

## Problema de negocio

Los recursos comerciales de VueloJusto son limitados y deben asignarse estratégicamente.

**La pregunta central del proyecto es:**

> ¿Qué aeropuertos europeos presentan el mayor potencial comercial para VueloJusto al combinar una participación significativa en el mercado con un crecimiento sostenido del tráfico aéreo?

## Objetivos

- Analizar la distribución del tráfico aéreo europeo por país y aeropuerto.
- Identificar los principales hubs aeroportuarios.
- Evaluar la evolución del tráfico entre 2016 y 2022.
- Medir la recuperación posterior a la pandemia.
- Construir un indicador compuesto para priorizar mercados.
- Desarrollar un tablero ejecutivo para apoyar la toma de decisiones.

## Conjunto de datos

Conjunto de datos de vuelos europeos ([Kaggle](https://www.kaggle.com/datasets/umerhaddii/european-flights-dataset), acceso público)

| Característica | Valor |
|---|---|
| Registros | 688.099 |
| Países | 42 |
| Aeropuertos | 332 |
| Cobertura temporal | 2016–2022 (hasta mayo de 2022) |
| Granularidad | Aeropuerto × Día |

**Variables principales:** País, Aeropuerto, Fecha, Llegadas, Salidas, Movimientos totales, Operaciones IFR.

## Arquitectura del proyecto

El proyecto implementa una arquitectura analítica escalonada para preservar la trazabilidad de los datos y documentar todas las transformaciones.

```
Flights.csv
      ↓
SQL Server (AirportMarketDB)
      ↓
Flights_Raw
      ↓
EDA & Data Quality
      ↓
Power Query (ETL)
      ↓
Star Schema
      ↓
Power BI
      ↓
Dashboard Ejecutivo
```

## Modelo dimensional

El tablero se construyó sobre un **esquema estrella**.

- **Tabla de hechos:** `Fact_TraficoAereo`
- **Dimensiones:** `Dim_Fecha`, `Dim_Aeropuerto`, `Dim_Pais`

Este modelo permite optimizar el rendimiento del tablero y facilitar el desarrollo de medidas DAX.

## Metodología

1. Importación y validación del conjunto de datos.
2. Análisis exploratorio (EDA).
3. Evaluación de calidad de datos.
4. Modelado dimensional.
5. Transformación mediante Power Query.
6. Desarrollo de medidas DAX.
7. Construcción del dashboard.
8. Data Storytelling y recomendaciones estratégicas.

### Principales decisiones metodológicas

- Validación del **grano real del dataset** (aeropuerto × día).
- Corrección de una **inconsistencia de nomenclatura** del aeropuerto LLBG.
- Utilización de **movimientos totales** como métrica principal debido a la baja completitud de las variables IFR.
- **Exclusión de LTFM** (iGA Istanbul Airport) del componente de crecimiento por el efecto estructural de su apertura operativa.
- **Comparación de períodos homogéneos** para el cálculo de la recuperación de 2022 (enero-mayo 2022 vs. enero-mayo 2019, no año completo vs. año completo).

## Congestion Opportunity Score (COS)

El principal aporte analítico del proyecto es el desarrollo del **Congestion Opportunity Score (COS)**.

El indicador combina:

- Participación de mercado normalizada
- Crecimiento sostenido normalizado

```
COS = 0.50 × Market Share + 0.50 × Growth Score
```

El crecimiento se calcula como el promedio de crecimiento interanual entre 2018 y 2019, utilizando únicamente aeropuertos que cumplen criterios mínimos de elegibilidad (más de 200.000 vuelos totales en el período y al menos 10.000 vuelos en cada uno de 2017, 2018 y 2019) — este umbral evita que aeropuertos regionales con series históricas incompletas o de muy bajo volumen distorsionen el ranking con variaciones porcentuales extremas.

## Panel

El tablero está organizado en cinco páginas:

1. **Executive Overview** — resumen ejecutivo
2. **Country Analysis** — análisis de países
3. **Airport Analysis** — análisis de aeropuertos
4. **Air Traffic Evolution** — evolución del tráfico aéreo
5. **Strategic Opportunities** — oportunidades estratégicas

Cada página responde una pregunta específica de negocio y forma parte de una narrativa analítica progresiva.

### Indicadores principales

- Vuelos totales
- Cuota de mercado por país
- Cuota de mercado por aeropuerto
- Crecimiento de los aeropuertos (%)
- Recuperación vs. 2019 (período comparable)
- Congestion Opportunity Score (COS)

## Principales resultados

- **87.056.538** movimientos aéreos analizados.
- Los **cinco principales países** (España, Alemania, Reino Unido, Francia, Italia) concentran el **55,6%** del tráfico europeo.
- **84 de 332 aeropuertos (25,3%)** generan aproximadamente el 80% del tráfico total.
- El tráfico cayó un **56,8%** en 2020 respecto de 2019.
- La recuperación alcanzó el **76,6%** del período prepandemia comparable (enero–mayo 2022 vs. enero–mayo 2019).
- **Frankfurt, Milán-Malpensa y Antalya** emergen como los mercados con mayor potencial estratégico según el COS — Frankfurt por su gran escala combinada con crecimiento aún sólido, y Milán-Malpensa y Antalya por combinar volumen significativo con las tasas de crecimiento sostenido más altas del mercado.

## Tecnologías utilizadas

SQL Server · Power Query (M) · DAX · Power BI · Modelado dimensional · Business Intelligence · Visualización de datos · Data Storytelling

## Estructura del repositorio

```
vuelojusto-airport-market-intelligence/
│
├── README.md
│
├── PDF/
│   └── VueloJusto_Business_Intelligence.pdf
│
├── powerbi/
│   └── VueloJusto_Airport_Market_Intelligence.pbix
│
├── sql/
│   ├── 01_import_dataset.sql
│   ├── 02_exploratory_analysis.sql
│   ├── 03_data_quality.sql
│   ├── 04_star_schema.sql
│   └── 05_business_queries.sql  
│
└── images/
    ├── dashboard_overview.png
    ├── dashboard_country_analysis.png
    ├── dashboard_airport_analysis.png
    ├── dashboard_air_traffic_evolution.png
    └── dashboard_strategic_opportunities.png
```

## Limitaciones

El proyecto utiliza información histórica de tráfico aéreo y no incorpora:

- demoras,
- cancelaciones,
- capacidad aeroportuaria,
- conectividad de rutas,
- participación de aerolíneas,
- ni variables económicas regionales.

El COS constituye un **indicador de priorización estratégica**, no una medición operativa certificada de congestión aeroportuaria.

## Autor

**Gerónimo Daguerre**

Análisis de datos · Inteligencia empresarial · SQL · Power BI · DAX · Visualización de datos

GitHub: [https://github.com/gdaguerre-dot](https://github.com/gdaguerre-dot)

## Licencia

Este proyecto fue desarrollado con fines educativos y de portafolio profesional utilizando un conjunto de datos de acceso público disponible en Kaggle. Ver [LICENSE](LICENSE) para más detalles.
