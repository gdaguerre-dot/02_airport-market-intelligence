# Inteligencia de mercado aeroportuario

`Power BI` · `Power Query (M)` · `DAX` · `Business Intelligence` · `Storytelling` · `Aviation Industry`

Caso real de análisis aeroportuario: qué mercados europeos presentan mayor riesgo estructural de congestión — y por lo tanto, mayor oportunidad de negocio para una plataforma de compensación aérea — aplicando criterios reales de gestión aeroportuaria, no solo volumen de tráfico.

📄 Documentación completa: [`pdf/Airport_Market_Intelligence.pdf`](pdf/Airport_Market_Intelligence.pdf)

📊 Panel de control de Power BI: [`powerbi/Airport_Market_Intelligence.pbix`](powerbi/Airport_Market_Intelligence.pbix)

## Caso de negocio: VueloJusto

VueloJusto es una plataforma de compensación de pasajeros afectados por demoras y cancelaciones de vuelos, con sede en el Aeropuerto de Palma de Mallorca. Las demoras que generan un reclamo de compensación rara vez son un evento aislado: casi siempre son la consecuencia de un desequilibrio estructural entre la capacidad de un aeropuerto y la demanda que recibe.

**Pregunta de negocio:** ¿Qué aeropuertos europeos muestran mayor riesgo estructural de congestión — por crecimiento sostenido de tráfico sin señales de expansión de capacidad — y representan por lo tanto mayor probabilidad de demoras, mayor riesgo operativo para las aerolíneas y mayor oportunidad de negocio para una plataforma de compensación aérea como VueloJusto?

## Por qué este proyecto es distinto a un tablero de tráfico aéreo

La mayoría de los análisis de tráfico aéreo se detienen en el volumen: qué país o aeropuerto mueve más vuelos. Este proyecto va un paso más allá, aplicando la relación entre capacidad, demanda y retraso (OACI) para transformar el dato de tráfico en un indicador de riesgo.

El volumen de operaciones se usa como proxy de demanda (el dataset no incluye datos individuales de pasajeros ni de demoras), pero la priorización final no se basa solo en volumen — combina crecimiento sostenido de tráfico (como proxy de tensión entre capacidad y demanda) con volumen relativo, en un **Índice de Riesgo de Congestión** construido íntegramente en DAX.

## Conjunto de datos

| Métrica | Valor |
|---|---|
| Registros | 688.099 |
| Países | 42 |
| Aeropuertos | 332 (333 nombres, ver nota de calidad de datos) |
| Período | 2016-01-01 a 2022-05-31 (2022 es un año parcial: enero–mayo) |
| Grano | **Diario** por aeropuerto (columna `FLT_DATE`) — no mensual |
| Fuente | [European Flights Dataset — Kaggle](https://www.kaggle.com/datasets/umerhaddii/european-flights-dataset) |

Variables principales: país (`STATE_NAME`), aeropuerto (`APT_ICAO`, `APT_NAME`), fecha (`FLT_DATE`, `YEAR`, `MONTH_NUM`), salidas/llegadas/movimientos totales (`FLT_DEP_1`, `FLT_ARR_1`, `FLT_TOT_1`), y sus equivalentes bajo reglas de vuelo instrumental (`FLT_*_IFR_2`).

**Nota de calidad de datos:** las columnas IFR (`FLT_TOT_IFR_2` y relacionadas) tienen ~70% de valores nulos (`NA`), por lo que el volumen de operaciones del modelo se calcula sobre `FLT_TOT_1` (total de movimientos), no sobre las columnas IFR.

## Modelo de datos

Esquema de estrella:

- **Tabla de hechos:** `Fact_TraficoAereo`
- **Dimensiones:** `Dim_Fecha`, `Dim_Aeropuerto`, `Dim_Pais`

## Indicadores clave de rendimiento (KPI)

| KPI | Qué mide |
|---|---|
| Total de Operaciones | Volumen base del mercado |
| Contribución de los 5 países principales | Concentración de mercado por país |
| % Acumulado Pareto (Principales aeropuertos) | Concentración de mercado por hub |
| Crecimiento interanual % | Evolución interanual del tráfico |
| Tasa de recuperación en comparación con 2019 | Velocidad y estabilidad de recuperación post-COVID |
| Índice de Riesgo de Congestión | Volumen relativo × crecimiento sostenido |

KPI complementario (contextual): Ingreso Comercial de Referencia, calculado a partir de un valor de gasto medio por pasajero tomado de benchmarks públicos del sector — se usa como nota de contexto en las recomendaciones, no como medida central del tablero.

## Principales hallazgos

- Un número reducido de países y aeropuertos concentra una proporción significativa del tráfico aéreo europeo: los 5 países principales (España, Alemania, Reino Unido, Francia, Italia) concentran el **55,6%** del tráfico total, y solo **84 de 333 aeropuertos (25,2%)** explican el 80% del volumen (Pareto).
- España, Alemania, Reino Unido y Francia se confirman como los mercados de mayor volumen y estabilidad.
- El tráfico aéreo sufrió una contracción histórica en 2020 (**-56,8%** vs. 2019), con una recuperación gradual y desigual: 2021 alcanzó el 53,8% del volumen 2019, y el período Ene-May 2022 alcanzó el 77,1% del mismo período de 2019.
- Existen aeropuertos con crecimiento sostenido por encima del promedio de mercado que no coinciden con los de mayor volumen absoluto (ej. Antalya, Milán-Malpensa, Sevilla) — el riesgo de congestión no siempre está donde está el tráfico más grande, sino donde crece más rápido.

## Recomendaciones estratégicas

**Corto plazo** — Gestión de riesgo operativo antes de la expansión comercial. Priorizar para alianzas comerciales los mercados con Índice de Riesgo de Congestión alto, anticipando mayor volumen de gestión de reclamos.

**Mediano plazo** — Monitoreo diferenciado por tipo de riesgo. Distinguir entre hubs grandes ya cerca de su límite estructural (ej. Frankfurt, Madrid-Barajas) y aeropuertos medianos con crecimiento acelerado que se acercan a uno (ej. Antalya, Milán-Malpensa) — cada perfil requiere una estrategia de monitoreo distinta.

**Largo plazo** — Recuperación post-COVID como filtro de riesgo antes de invertir. Priorizar para compromisos comerciales de mayor plazo (3-7 años) los mercados que combinan alto riesgo de congestión con una recuperación post-2019 rápida y sostenida.

## Tecnologías utilizadas

Power BI · Power Query (M) · DAX · Modelado Dimensional (Star Schema) · SQL (validación inicial) · Storytelling con datos

## Estructura del repositorio

```
README.md
pdf/
    Airport_Market_Intelligence.pdf
sql/
    01_validacion_duplicados.sql
    02_validacion_cobertura_temporal.sql
powerbi/
    Airport_Market_Intelligence.pbix
images/
    modelo_estrella.png
    dashboard_vista_general.png
    dashboard_riesgo_congestion.png
```

## Limitaciones del análisis

El conjunto de datos no contiene información de demoras, cancelaciones ni capacidad declarada por aeropuerto — el Índice de Riesgo de Congestión es un indicador direccional construido a partir de proxies declarados (volumen y crecimiento sostenido), no una medición operativa certificada. El conjunto de datos utilizado es público y corresponde a Kaggle, no a información interna de la compañía. El KPI de Ingreso Comercial de Referencia utiliza un valor de referencia público, no cifras financieras reales. 2022 es un año incompleto (enero-mayo) en el dataset fuente. El aeropuerto iGA Istanbul (LTFM) se excluye del ranking de crecimiento sostenido por tratarse de un aeropuerto de apertura reciente (2019), cuyo crecimiento refleja una puesta en operación y no tensión capacidad-demanda orgánica.

## Autor

**Gerónimo Daguerre** — Business Intelligence · Análisis de Datos · Operaciones Turísticas y de Aviación

[LinkedIn](https://www.linkedin.com/in/TU-USUARIO-AQUI) · [GitHub](https://github.com/TU-USUARIO-AQUI)

## Licencia

Proyecto desarrollado con fines educativos y de portafolio profesional, sobre un conjunto de datos público de Kaggle.
