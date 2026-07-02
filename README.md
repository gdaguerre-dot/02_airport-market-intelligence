# Airport Market Intelligence

`Power BI` · `Power Query (M)` · `DAX` · `Business Intelligence` · `Storytelling` · `Aviation Industry`

> Caso real de análisis aeroportuario: qué mercados europeos presentan mayor riesgo estructural de congestión — y por lo tanto, mayor oportunidad de negocio para una plataforma de compensación aérea — aplicando criterios reales de gestión aeroportuaria, no solo volumen de tráfico.

📄 **Documentación completa:** [`pdf/Airport_Market_Intelligence.pdf`](./pdf/Airport_Market_Intelligence.pdf)

📊 **Dashboard Power BI:** [`powerbi/Airport_Market_Intelligence.pbix`](./powerbi/)

---

## Caso de negocio: VueloJusto

Durante 2023–2024 trabajé como Coordinador de Gestión de Proyectos en **VueloJusto**, una plataforma de compensación de pasajeros afectados por demoras y cancelaciones de vuelos, y posteriormente como Especialista en Operaciones y Experiencia del Cliente en el **Aeropuerto de Palma de Mallorca**, junto con una formación formal en Gestión Aeroportuaria (ITAérea – UDIMA).

Esa experiencia dejó una idea central: las demoras que generan un reclamo de compensación rara vez son un evento aislado — casi siempre son la consecuencia visible de un desequilibrio estructural entre la capacidad de un aeropuerto y la demanda que recibe.

**Pregunta de negocio:**
¿Qué aeropuertos europeos muestran mayor riesgo estructural de congestión — por crecimiento sostenido de tráfico sin señales de expansión de capacidad — y representan por lo tanto mayor probabilidad de demoras, mayor riesgo operativo para las aerolíneas y mayor oportunidad de negocio para una plataforma de compensación aérea como VueloJusto?

## Por qué este proyecto es distinto a un dashboard de tráfico aéreo

La mayoría de los análisis de tráfico aéreo se detienen en el volumen: qué país o aeropuerto mueve más vuelos. Este proyecto va un paso más allá, aplicando la relación entre capacidad, demanda y retraso (OACI) para transformar el dato de tráfico en un indicador de riesgo:

- El volumen de operaciones se usa como proxy de demanda (el dataset no incluye datos individuales de pasajeros ni de demoras), pero la priorización final no se basa solo en volumen — combina **crecimiento sostenido de tráfico** (como proxy de tensión entre capacidad y demanda) con volumen relativo, en un **Índice de Riesgo de Congestión** construido íntegramente en DAX.
- Esta capa de interpretación surge de experiencia real en operaciones aeroportuarias y en una plataforma de compensación aérea — no es una inferencia genérica sobre el dataset.
- **VueloJusto es un empleador real del autor.** El dataset utilizado es público (Kaggle); el caso de negocio se construye aplicando el criterio adquirido en ese rol sobre datos públicos, no sobre información interna de la compañía.

## Enfoque técnico: Power BI de punta a punta

A diferencia del Capítulo 01 de esta serie (SIGP-LLULL, centrado en SQL), este proyecto está pensado como demostración de dominio integral de Power BI: el SQL se usa únicamente para una validación puntual del dataset antes de cargarlo (duplicados, cobertura temporal). Desde ahí en adelante, **toda la limpieza, transformación y lógica analítica —incluida la construcción de dimensiones y el Índice de Riesgo de Congestión— se resuelve nativamente en Power Query (M) y DAX.**

## Dataset

| Métrica | Valor |
|---|---|
| Registros | 688.099 |
| Países | 42 |
| Aeropuertos | 332 |
| Período | 2016–2022 |
| Fuente | [European Flights Dataset — Kaggle](https://www.kaggle.com/datasets/umerhaddii/european-flights-dataset) |

**Variables principales:** país, aeropuerto, año, mes, operaciones IFR, llegadas, salidas, movimientos totales.

## Modelo de datos

Esquema de estrella:

- **Tabla de hechos:** `Fact_TraficoAereo`
- **Dimensiones:** `Dim_Fecha`, `Dim_Aeropuerto`, `Dim_Pais`

## KPIs

| KPI | Qué mide |
|---|---|
| Total de Operaciones | Volumen base del mercado |
| Top 5 Countries Contribution | Concentración de mercado por país |
| % Acumulado Pareto (Top Airports) | Concentración de mercado por hub |
| YoY Growth % | Evolución interanual del tráfico |
| Recovery Rate vs. 2019 | Velocidad y estabilidad de recuperación post-COVID |
| **Índice de Riesgo de Congestión** | Volumen relativo × crecimiento sostenido — KPI diferencial del proyecto |

*KPI complementario (contextual): Ingreso Comercial de Referencia, calculado a partir de un valor de gasto medio por pasajero tomado de benchmarks públicos del sector — se usa como nota de contexto en las recomendaciones, no como medida central del dashboard.*

## Principales hallazgos

- Un número reducido de países y aeropuertos concentra una proporción significativa del tráfico aéreo europeo.
- España, Alemania, Reino Unido y Francia se perfilan como los mercados de mayor volumen y estabilidad.
- El tráfico aéreo sufrió una contracción histórica en 2020, con una recuperación gradual y desigual entre mercados.
- Existen aeropuertos con crecimiento sostenido por encima del promedio de mercado que no necesariamente coinciden con los de mayor volumen absoluto — el riesgo de congestión no siempre está donde está el tráfico más grande, sino donde crece más rápido.

## Recomendaciones estratégicas

**Corto plazo — Gestión de riesgo operativo antes que expansión comercial.**
Priorizar para alianzas comerciales los mercados con Índice de Riesgo de Congestión alto, anticipando mayor volumen de gestión de reclamos.

**Mediano plazo — Monitoreo diferenciado por tipo de riesgo.**
Distinguir entre hubs grandes ya cerca de su límite estructural y aeropuertos medianos con crecimiento acelerado que se acercan a uno — cada perfil requiere una estrategia de monitoreo distinta.

**Largo plazo — Recuperación post-COVID como filtro de riesgo antes de invertir.**
Priorizar para compromisos comerciales de mayor plazo (3-7 años) los mercados que combinan alto riesgo de congestión con una recuperación post-2019 rápida y sostenida.

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

El dataset no contiene información de demoras, cancelaciones ni capacidad declarada por aeropuerto — el Índice de Riesgo de Congestión es un indicador direccional construido a partir de proxies declarados (volumen y crecimiento sostenido), no una medición operativa certificada. VueloJusto es un empleador real del autor; el dataset utilizado es público y no corresponde a información interna de la compañía. El KPI de Ingreso Comercial de Referencia usa un valor de benchmark público, no cifras financieras reales de VueloJusto ni de los aeropuertos analizados.

## Autor

**Gerónimo Daguerre**
Business Intelligence · Análisis de Datos · Operaciones Turísticas y de Aviación

[LinkedIn](https://www.linkedin.com/in/gerodaguerre/) · [GitHub](https://github.com/gdaguerre-dot)

## Licencia

Proyecto desarrollado con fines educativos y de portfolio profesional, sobre un dataset público de Kaggle. El caso de negocio (VueloJusto) corresponde a un empleador real del autor; los criterios de priorización aplicados se apoyan en experiencia profesional real en el sector aeroportuario y turístico, no en datos internos o confidenciales de la compañía.
