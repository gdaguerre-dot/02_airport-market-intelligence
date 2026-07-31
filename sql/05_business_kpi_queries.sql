/******************************************************************************
 Proyecto : Airport Market Intelligence
 Autor    : Gerónimo Daguerre
 Archivo  : 05_business_kpi_queries.sql

 Objetivo
 --------
 Generar las consultas SQL que sustentan los principales indicadores (KPIs)
 utilizados en el dashboard de Power BI y permiten responder la pregunta
 de negocio del proyecto.

 Base de datos
 -------------
 AirportMarketDB

 Tabla origen
 ------------
 Flights_Raw

 Descripción
 -----------
 Este script reúne consultas analíticas orientadas al negocio.

 Aunque los indicadores finales serán implementados mediante medidas DAX
 en Power BI, las consultas desarrolladas permiten validar previamente
 los resultados y documentar la lógica de cálculo utilizada durante el
 proyecto.

 Dependencias
 ------------
 Este script asume que previamente se ejecutaron:

 • 01_importacion_dataset.sql
 • 02_exploratory_data_analysis.sql
 • 03_data_quality_assessment.sql
 • 04_star_schema_design.sql

******************************************************************************/

USE AirportMarketDB;
GO

/******************************************************************************
 KPI 1 - Total de operaciones
******************************************************************************/

SELECT

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw;


/******************************************************************************
 KPI 2 - Operaciones por país
******************************************************************************/

SELECT

STATE_NAME,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY STATE_NAME

ORDER BY Total_Operaciones DESC;


/******************************************************************************
 KPI 3 - Top 10 aeropuertos
******************************************************************************/

SELECT TOP (10)

APT_NAME,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY APT_NAME

ORDER BY Total_Operaciones DESC;


/******************************************************************************
 KPI 4 - Evolución anual del tráfico
******************************************************************************/

SELECT

YEAR,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY YEAR

ORDER BY YEAR;


/******************************************************************************
 KPI 5 - Evolución mensual
******************************************************************************/

SELECT

YEAR,

MONTH_NUM,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY

YEAR,

MONTH_NUM

ORDER BY

YEAR,

MONTH_NUM;


/******************************************************************************
 KPI 6 - Participación porcentual por país
******************************************************************************/

SELECT

STATE_NAME,

SUM(FLT_TOT_1) AS Total_Operaciones,

ROUND(

100.0 * SUM(FLT_TOT_1)

/ SUM(SUM(FLT_TOT_1)) OVER(),

2

) AS Participacion_Porcentual

FROM Flights_Raw

GROUP BY STATE_NAME

ORDER BY Participacion_Porcentual DESC;


/******************************************************************************
 KPI 7 - Ranking de aeropuertos
******************************************************************************/

SELECT

APT_NAME,

SUM(FLT_TOT_1) AS Total_Operaciones,

RANK() OVER(

ORDER BY SUM(FLT_TOT_1) DESC

) AS Ranking

FROM Flights_Raw

GROUP BY APT_NAME;


/******************************************************************************
 KPI 8 - Top 5 países
******************************************************************************/

SELECT TOP (5)

STATE_NAME,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY STATE_NAME

ORDER BY Total_Operaciones DESC;


/******************************************************************************
 KPI 9 - Recuperación post COVID
******************************************************************************/

SELECT

YEAR,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

WHERE YEAR >= 2019

GROUP BY YEAR

ORDER BY YEAR;


/******************************************************************************
 KPI 10 - Aeropuertos con mayor crecimiento
******************************************************************************/

SELECT TOP (20)

APT_NAME,

YEAR,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY

APT_NAME,

YEAR

ORDER BY

APT_NAME,

YEAR;


/******************************************************************************
 KPI 11 - Pareto de aeropuertos
******************************************************************************/

SELECT

APT_NAME,

SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY APT_NAME

ORDER BY Total_Operaciones DESC;


/******************************************************************************
 KPI 12 - Operaciones promedio por aeropuerto
******************************************************************************/

SELECT

AVG(TotalOperaciones) AS Promedio_Operaciones

FROM

(

SELECT

APT_ICAO,

SUM(FLT_TOT_1) AS TotalOperaciones

FROM Flights_Raw

GROUP BY APT_ICAO

) AS Operaciones;


/******************************************************************************
 Observaciones
******************************************************************************/

-- Las consultas desarrolladas representan la base analítica utilizada
-- para construir los indicadores del dashboard.

-- Los cálculos finales serán implementados mediante medidas DAX,
-- aprovechando el contexto de filtros y el modelo dimensional.

-- SQL permitió validar la consistencia de los resultados obtenidos
-- posteriormente en Power BI.

-- Las variables IFR fueron excluidas de los KPIs debido a la elevada
-- proporción de valores "NA" identificada durante la etapa de Data Quality.

-- El Congestion Opportunity Score (COS) será calculado en Power BI
-- mediante DAX, ya que requiere combinar múltiples métricas,
-- normalización y contexto dinámico de filtros.


/******************************************************************************
 Conclusión
******************************************************************************/

-- Las consultas desarrolladas permiten validar los principales indicadores
-- utilizados para responder la pregunta de negocio del proyecto.

-- Se documentó la lógica de cálculo correspondiente a:

-- ✔ Total de operaciones.
-- ✔ Participación por país.
-- ✔ Ranking de aeropuertos.
-- ✔ Evolución temporal.
-- ✔ Concentración del mercado.
-- ✔ Recuperación post pandemia.

-- Este script constituye el puente entre la preparación de datos en SQL
-- y el desarrollo del modelo analítico en Power BI, garantizando la
-- trazabilidad de los indicadores implementados mediante DAX.

******************************************************************************
