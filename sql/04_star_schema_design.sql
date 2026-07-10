/******************************************************************************
 Proyecto : Airport Market Intelligence
 Autor    : Gerónimo Daguerre
 Archivo  : 04_star_schema_design.sql

 Objetivo
 --------
 Documentar el diseño del modelo dimensional del proyecto y generar las
 consultas base para la construcción de las dimensiones utilizadas en
 Power BI.

 Base de datos
 -------------
 AirportMarketDB

 Tabla origen
 ------------
 Flights_Raw

 Descripción
 -----------
 Este script corresponde a la etapa de Modelado Dimensional.

 El modelo analítico adopta un esquema en estrella (Star Schema),
 optimizado para consultas analíticas y desarrollo de dashboards.

 Las dimensiones serán construidas posteriormente en Power Query,
 utilizando como origen las consultas documentadas en este script.

 /******************************************************************************
 Justificación del modelo

 Se adopta un esquema en estrella debido a que:

 • Reduce la complejidad del modelo.
 • Optimiza el rendimiento en Power BI.
 • Facilita el desarrollo de medidas DAX.
 • Simplifica la navegación mediante filtros.
 • Sigue las recomendaciones de Microsoft para modelos analíticos.

******************************************************************************/

 Dependencias
 ------------
 Este script asume que previamente se ejecutaron:

 • 01_importacion_dataset.sql
 • 02_exploratory_data_analysis.sql
 • 03_data_quality_assessment.sql

******************************************************************************/

USE AirportMarketDB;
GO

/******************************************************************************
 Modelo Dimensional
******************************************************************************/

-- Esquema en estrella

--                Dim_Fecha
--                    |
--                    |
-- Dim_Pais ---- Fact_TraficoAereo ---- Dim_Aeropuerto
--
--
-- Tabla de hechos:
--
-- Fact_TraficoAereo
--
-- Medidas:
--
-- FLT_DEP_1
-- FLT_ARR_1
-- FLT_TOT_1
--
-- Dimensiones:
--
-- Fecha
-- País
-- Aeropuerto


/******************************************************************************
 Dimensión Fecha
******************************************************************************/

-- Consulta base para la dimensión Fecha.

SELECT DISTINCT

    FLT_DATE,

    YEAR,

    MONTH_NUM,

    MONTH_MON

FROM Flights_Raw

ORDER BY FLT_DATE;


/******************************************************************************
 Dimensión País
******************************************************************************/

SELECT DISTINCT

    STATE_NAME

FROM Flights_Raw

ORDER BY STATE_NAME;


/******************************************************************************
 Dimensión Aeropuerto
******************************************************************************/

SELECT DISTINCT

    APT_ICAO,

    APT_NAME,

    STATE_NAME

FROM Flights_Raw

ORDER BY APT_NAME;


/******************************************************************************
 Tabla de Hechos
******************************************************************************/

-- Consulta base de la tabla de hechos.

SELECT

    FLT_DATE,

    APT_ICAO,

    STATE_NAME,

    FLT_DEP_1,

    FLT_ARR_1,

    FLT_TOT_1

FROM Flights_Raw;


/******************************************************************************
 Validaciones del modelo
******************************************************************************/

-- Cantidad de fechas.

SELECT

COUNT(DISTINCT FLT_DATE) AS Total_Fechas

FROM Flights_Raw;


-- Cantidad de países.

SELECT

COUNT(DISTINCT STATE_NAME) AS Total_Paises

FROM Flights_Raw;


-- Cantidad de aeropuertos.

SELECT

COUNT(DISTINCT APT_ICAO) AS Total_Aeropuertos

FROM Flights_Raw;


/******************************************************************************
 Relaciones esperadas
******************************************************************************/

-- Dim_Fecha
--
-- FLT_DATE
--        |
--        |
-- Fact_TraficoAereo
--
--
-- Dim_Aeropuerto
--
-- APT_ICAO
--        |
--        |
-- Fact_TraficoAereo
--
--
-- Dim_Pais
--
-- STATE_NAME
--        |
--        |
-- Fact_TraficoAereo


/******************************************************************************
 Observaciones
******************************************************************************/

-- El modelo adopta una arquitectura Star Schema.

-- Se priorizó un modelo simple y altamente performante para análisis OLAP.

-- La tabla Flights_Raw no será utilizada directamente en Power BI.

-- Las dimensiones serán construidas mediante Power Query a partir de
-- las consultas documentadas en este script.

-- La tabla de hechos almacenará únicamente medidas cuantitativas y
-- claves de relación.

-- La separación entre dimensiones y hechos facilitará la construcción
-- de medidas DAX, relaciones y segmentaciones.


/******************************************************************************
 Conclusión
******************************************************************************/

-- El modelo dimensional diseñado permite organizar la información de
-- manera eficiente para responder la pregunta de negocio del proyecto.

-- Se definieron:

-- ✔ Dimensión Fecha.
-- ✔ Dimensión País.
-- ✔ Dimensión Aeropuerto.
-- ✔ Tabla de Hechos.

-- El esquema en estrella facilitará la construcción del dashboard,
-- optimizará el rendimiento de las consultas analíticas y permitirá
-- desarrollar indicadores mediante DAX siguiendo las buenas prácticas
-- de Business Intelligence.

******************************************************************************
