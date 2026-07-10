/******************************************************************************
 Proyecto : Airport Market Intelligence
 Autor    : Gerónimo Daguerre
 Archivo  : 02_exploratory_data_analysis.sql

 Objetivo
 --------
 Realizar el análisis exploratorio (Exploratory Data Analysis - EDA) del
 dataset Flights_Raw con el fin de comprender su estructura, distribución,
 cobertura temporal y principales características antes de iniciar el proceso
 de limpieza y transformación de datos.

 Base de datos
 -------------
 AirportMarketDB

 Tabla
 -----
 Flights_Raw

 Descripción
 -----------
 El análisis exploratorio constituye la primera aproximación analítica al
 conjunto de datos.

 Durante esta etapa se busca comprender la composición del dataset,
 identificar patrones generales, detectar posibles anomalías y generar una
 visión global que facilite las posteriores tareas de Data Quality,
 transformación y modelado dimensional.

 Dependencias
 ------------
 Este script asume que:

 • AirportMarketDB ya existe.
 • Flights_Raw fue importada correctamente.
 • Se ejecutó previamente el script
   01_importacion_dataset.sql.

******************************************************************************/

USE AirportMarketDB;
GO

/******************************************************************************
 1. Tamaño del dataset
******************************************************************************/

-- Cantidad total de registros.

SELECT
    COUNT(*) AS Total_Registros
FROM Flights_Raw;


-- Cantidad de aeropuertos distintos.

SELECT
    COUNT(DISTINCT APT_ICAO) AS Total_Aeropuertos
FROM Flights_Raw;


-- Cantidad de países.

SELECT
    COUNT(DISTINCT STATE_NAME) AS Total_Paises
FROM Flights_Raw;


/******************************************************************************
 2. Cobertura temporal
******************************************************************************/

-- Primer y último día del dataset.

SELECT
    MIN(FLT_DATE) AS Fecha_Inicial,
    MAX(FLT_DATE) AS Fecha_Final
FROM Flights_Raw;


-- Cantidad de años disponibles.

SELECT DISTINCT
    YEAR
FROM Flights_Raw
ORDER BY YEAR;


-- Cantidad de meses disponibles.

SELECT DISTINCT
    MONTH_NUM,
    MONTH_MON
FROM Flights_Raw
ORDER BY MONTH_NUM;


/******************************************************************************
 3. Variables categóricas
******************************************************************************/

-- Países incluidos.

SELECT
    STATE_NAME
FROM Flights_Raw
GROUP BY STATE_NAME
ORDER BY STATE_NAME;


-- Aeropuertos distintos.

SELECT
    COUNT(DISTINCT APT_NAME) AS Total_Nombres_Aeropuerto
FROM Flights_Raw;


/******************************************************************************
 4. Distribución del tráfico
******************************************************************************/

-- Top 10 países por cantidad de operaciones.

SELECT TOP (10)

    STATE_NAME,

    SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY STATE_NAME

ORDER BY Total_Operaciones DESC;


-- Top 10 aeropuertos por operaciones.

SELECT TOP (10)

    APT_NAME,

    SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY APT_NAME

ORDER BY Total_Operaciones DESC;


/******************************************************************************
 5. Evolución anual del tráfico
******************************************************************************/

SELECT

    YEAR,

    SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw

GROUP BY YEAR

ORDER BY YEAR;


/******************************************************************************
 6. Estadísticas descriptivas
******************************************************************************/

SELECT

    MIN(FLT_TOT_1) AS Minimo,

    MAX(FLT_TOT_1) AS Maximo,

    AVG(FLT_TOT_1) AS Promedio,

    SUM(FLT_TOT_1) AS Total_Operaciones

FROM Flights_Raw;


/******************************************************************************
 7. Valores IFR
******************************************************************************/

-- Primera inspección de las variables IFR.

SELECT TOP (20)

    FLT_DEP_IFR_2,

    FLT_ARR_IFR_2,

    FLT_TOT_IFR_2

FROM Flights_Raw;


/******************************************************************************
 Observaciones
******************************************************************************/

-- El dataset contiene información diaria del tráfico aéreo europeo.

-- La cobertura temporal comprende el período 2016–2022.

-- El año 2022 corresponde únicamente al período enero-mayo.

-- La variable FLT_TOT_1 representa el volumen total de operaciones
-- y constituye la principal medida del proyecto.

-- Se observa la existencia de valores "NA" en las columnas IFR,
-- cuya calidad será evaluada en el siguiente script.

-- El análisis confirma la presencia de múltiples países y aeropuertos,
-- permitiendo realizar comparaciones geográficas y temporales.


/******************************************************************************
 Conclusión
******************************************************************************/

-- El análisis exploratorio permitió comprender la estructura general
-- del dataset y verificar que posee la cobertura necesaria para responder
-- la pregunta de negocio planteada.

-- Se identificó:

-- ✔ Cobertura temporal adecuada.
-- ✔ Diversidad geográfica.
-- ✔ Variables relevantes para el análisis.
-- ✔ Métrica principal (FLT_TOT_1).
-- ✔ Variables IFR que requerirán evaluación de calidad.

-- La siguiente etapa consistirá en realizar el análisis de calidad
-- de los datos (Data Quality), identificando valores nulos,
-- duplicados, inconsistencias y posibles anomalías antes de iniciar
-- el proceso de transformación y modelado dimensional.
