/******************************************************************************
 Proyecto : Airport Market Intelligence
 Autor    : Gerónimo Daguerre
 Archivo  : 03_data_quality_assessment.sql

 Objetivo
 --------
 Evaluar la calidad del dataset Flights_Raw mediante la identificación de
 registros duplicados, valores nulos, inconsistencias y posibles anomalías
 que puedan afectar el análisis y la construcción del modelo analítico.

 Base de datos
 -------------
 AirportMarketDB

 Tabla
 -----
 Flights_Raw

 Descripción
 -----------
 Este script corresponde a la etapa de Data Quality dentro de la arquitectura
 del proyecto.

 Su finalidad es medir la calidad del conjunto de datos antes de iniciar el
 proceso ETL y documentar las principales incidencias detectadas.

 Dependencias
 ------------
 Este script asume que:

 • AirportMarketDB ya existe.
 • Flights_Raw fue importada correctamente.
 • Se ejecutaron previamente los scripts:

      01_importacion_dataset.sql
      02_exploratory_data_analysis.sql

------------------------------------------------------------------------------
 Dimensiones de calidad evaluadas
------------------------------------------------------------------------------

 ✔ Completitud
 ✔ Unicidad
 ✔ Consistencia
 ✔ Validez
 ✔ Cobertura temporal

******************************************************************************/

USE AirportMarketDB;
GO

/******************************************************************************
 1. Cobertura temporal
******************************************************************************/

-- Verificar el período cubierto por el dataset.

SELECT

    MIN(FLT_DATE) AS Fecha_Minima,
    MAX(FLT_DATE) AS Fecha_Maxima,
    COUNT(DISTINCT FLT_DATE) AS Dias_Distintos

FROM Flights_Raw;


/******************************************************************************
 2. Valores nulos o vacíos
******************************************************************************/

-- Evaluar la presencia de valores nulos en las variables principales.

SELECT

    SUM(CASE WHEN YEAR IS NULL THEN 1 ELSE 0 END) AS Nulos_YEAR,
    SUM(CASE WHEN MONTH_NUM IS NULL THEN 1 ELSE 0 END) AS Nulos_MONTH,
    SUM(CASE WHEN FLT_DATE IS NULL THEN 1 ELSE 0 END) AS Nulos_FECHA,
    SUM(CASE WHEN APT_ICAO IS NULL THEN 1 ELSE 0 END) AS Nulos_ICAO,
    SUM(CASE WHEN APT_NAME IS NULL THEN 1 ELSE 0 END) AS Nulos_AEROPUERTO,
    SUM(CASE WHEN STATE_NAME IS NULL THEN 1 ELSE 0 END) AS Nulos_PAIS

FROM Flights_Raw;


/******************************************************************************
 3. Registros duplicados
******************************************************************************/

-- Verificar duplicados según el grano real del dataset
-- (Aeropuerto + Fecha).

SELECT

    YEAR,
    MONTH_NUM,
    FLT_DATE,
    APT_ICAO,
    COUNT(*) AS Cantidad

FROM Flights_Raw

GROUP BY

    YEAR,
    MONTH_NUM,
    FLT_DATE,
    APT_ICAO

HAVING COUNT(*) > 1;


/******************************************************************************
 4. Consistencia entre código ICAO y nombre del aeropuerto
******************************************************************************/

-- Detectar códigos ICAO asociados a más de un nombre.

SELECT

    APT_ICAO,
    COUNT(DISTINCT APT_NAME) AS Distinct_Names

FROM Flights_Raw

GROUP BY APT_ICAO

HAVING COUNT(DISTINCT APT_NAME) > 1;


-- Inspección del caso detectado.

SELECT DISTINCT

    APT_ICAO,
    APT_NAME

FROM Flights_Raw

WHERE APT_ICAO = 'LLBG';


/******************************************************************************
 5. Valores "NA"
******************************************************************************/

-- Cuantificar la presencia de valores "NA" en las columnas IFR.

SELECT

    SUM(CASE WHEN FLT_DEP_IFR_2 = 'NA' THEN 1 ELSE 0 END) AS DEP_IFR_NA,
    SUM(CASE WHEN FLT_ARR_IFR_2 = 'NA' THEN 1 ELSE 0 END) AS ARR_IFR_NA,
    SUM(CASE WHEN FLT_TOT_IFR_2 = 'NA' THEN 1 ELSE 0 END) AS TOT_IFR_NA

FROM Flights_Raw;


/******************************************************************************
 6. Valores negativos
******************************************************************************/

-- Verificar que no existan cantidades negativas.

SELECT *

FROM Flights_Raw

WHERE

       FLT_DEP_1 < 0
    OR FLT_ARR_1 < 0
    OR FLT_TOT_1 < 0;


/******************************************************************************
 7. Consistencia matemática
******************************************************************************/

-- Validar que:
-- Salidas + Llegadas = Total

SELECT *

FROM Flights_Raw

WHERE FLT_DEP_1 + FLT_ARR_1 <> FLT_TOT_1;


/******************************************************************************
 8. Integridad de códigos ICAO
******************************************************************************/

-- Verificar longitud del código ICAO.

SELECT DISTINCT

    APT_ICAO

FROM Flights_Raw

WHERE LEN(APT_ICAO) <> 4;


/******************************************************************************
 9. Países sin nombre
******************************************************************************/

SELECT *

FROM Flights_Raw

WHERE

    STATE_NAME IS NULL

    OR LTRIM(RTRIM(STATE_NAME)) = '';


/******************************************************************************
10. Aeropuertos sin nombre
******************************************************************************/

SELECT *

FROM Flights_Raw

WHERE

    APT_NAME IS NULL

    OR LTRIM(RTRIM(APT_NAME)) = '';


/******************************************************************************
11. Valores extremos
******************************************************************************/

-- Identificar los mayores volúmenes diarios de operaciones.

SELECT TOP (20)

    APT_NAME,
    FLT_DATE,
    FLT_TOT_1

FROM Flights_Raw

ORDER BY FLT_TOT_1 DESC;


/******************************************************************************
12. Distribución de registros por año
******************************************************************************/

SELECT

    YEAR,
    COUNT(*) AS Registros

FROM Flights_Raw

GROUP BY YEAR

ORDER BY YEAR;


/******************************************************************************
 Observaciones
******************************************************************************/

-- No se detectaron registros duplicados para la combinación
-- Fecha + Aeropuerto, correspondiente al grano real del dataset.

-- Las variables principales presentan un alto nivel de completitud.

-- Se detectó una única inconsistencia de nomenclatura:
-- el aeropuerto LLBG aparece asociado a dos nombres diferentes
-- ("Ben Gurion International" y
-- "Tel Aviv - Ben Gurion International").

-- La estandarización de dicho atributo se realizó posteriormente
-- durante el proceso ETL, antes de construir Dim_Aeropuerto,
-- garantizando la unicidad de la clave de negocio.

-- Las columnas IFR presentan una elevada proporción de valores "NA",
-- por lo que no fueron utilizadas como fuente principal para
-- la construcción de indicadores estratégicos.

-- La variable FLT_TOT_1 mantiene consistencia matemática con la suma
-- de llegadas y salidas.

-- Los códigos ICAO respetan el estándar internacional de cuatro caracteres.

-- El conjunto de datos presenta una calidad adecuada para continuar
-- con el proceso ETL.


/******************************************************************************
 Conclusión
******************************************************************************/

-- La evaluación de calidad permitió validar la confiabilidad del
-- conjunto de datos utilizado en el proyecto.

-- Se verificó:

-- ✔ Integridad estructural.
-- ✔ Ausencia de duplicados al grano correcto (Fecha + Aeropuerto).
-- ✔ Consistencia matemática de las operaciones.
-- ✔ Integridad de los códigos ICAO.
-- ✔ Alta completitud de las variables principales.
-- ✔ Identificación de columnas con alta proporción de valores "NA".
-- ✔ Detección de una inconsistencia de nomenclatura (LLBG),
--   corregida posteriormente durante el proceso ETL.

-- Como resultado se decidió:

-- ✔ Utilizar FLT_TOT_1 como principal indicador de tráfico aéreo.
-- ✔ Excluir las variables IFR del cálculo de KPIs por su baja completitud.
-- ✔ Estandarizar el nombre del aeropuerto LLBG antes de construir
--   Dim_Aeropuerto, preservando la unicidad de la clave de negocio.

-- El siguiente paso consiste en construir el modelo dimensional
-- que servirá de base para el desarrollo del dashboard
-- Airport Market Intelligence en Power BI.

******************************************************************************
