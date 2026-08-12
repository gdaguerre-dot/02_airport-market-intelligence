# DAX Measure Catalog

## Objetivo

Las siguientes medidas DAX fueron desarrolladas para implementar los indicadores analíticos utilizados por el dashboard ejecutivo.

Las medidas se organizaron por categorías funcionales para favorecer la mantenibilidad, reutilización y escalabilidad del modelo analítico.

| Categoría | Medidas Principales |
|---|---|
| **KPIs** | Total Flights, Total Countries, Total Airports, Average Flights per Airport |
| **Market Analysis** | Market Share %, Airport Market Share %, Market Share Normalized |
| **Time Intelligence** | Flights Previous Year, YoY Growth %, Flights 2019 Comparable, Recovery vs 2019 % |
| **Operations** | Total Arrivals, Total Departures |
| **Rankings** | Airport Rank, Country Rank, Top Airport, Top Airport Flights |
| **Growth Opportunities** | Airport Growth %, Max Growth, Growth Score, Congestion Opportunity Score (COS), Average COS, COS Rank, Top Opportunity Airport, Top Growth Airport |
| **Supporting Measures** | Max Flights |

---

# KPIs

## Total Flights

```DAX
Total Flights =
SUM(Fact_TraficoAereo[Vuelos_Totales])

Total Countries =
DISTINCTCOUNT(Dim_Pais[Pais])

Total Airports =
DISTINCTCOUNT(Dim_Aeropuerto[ICAO_Aeropuerto])

Average Flights per Airport =
DIVIDE(
    [Total Flights],
    [Total Airports]
)

# Market Analysis 

Market Share % =
DIVIDE(
    [Total Flights],
    CALCULATE(
        [Total Flights],
        ALL(Dim_Pais)
    )
)

Airport Market Share % =
DIVIDE(
    [Total Flights],
    CALCULATE(
        [Total Flights],
        ALL(Dim_Aeropuerto)
    )
)

Market Share Normalized =
DIVIDE(
    [Airport Market Share %],
    CALCULATE(
        MAXX(
            ALL(Dim_Aeropuerto),
            [Airport Market Share %]
        )
    )
)

# Time Intelligence

Flights Previous Year =
CALCULATE(
    [Total Flights],
    SAMEPERIODLASTYEAR(Dim_Fecha[Fecha])
)

YoY Growth % =
DIVIDE(
    [Total Flights] - [Flights Previous Year],
    [Flights Previous Year]
)

Flights 2019 Comparable =
VAR CurrentYear =
    SELECTEDVALUE(Dim_Fecha[Año])

RETURN
IF(
    CurrentYear = 2022,
    CALCULATE(
        [Total Flights],
        ALL(Dim_Fecha),
        Dim_Fecha[Año] = 2019,
        Dim_Fecha[Mes_Numero] <= 5
    ),
    CALCULATE(
        [Total Flights],
        ALL(Dim_Fecha),
        Dim_Fecha[Año] = 2019
    )
)

La medida utiliza 2019 como período de referencia para evaluar la recuperación del tráfico aéreo.

Cuando el contexto corresponde a 2022, se utiliza el período enero-mayo de 2019 para mantener comparabilidad con el período disponible en 2022.

Recovery vs 2019 % =
DIVIDE(
    [Total Flights],
    [Flights 2019 Comparable]
)

# Operations

Total Arrivals =
SUM(Fact_TraficoAereo[Vuelos_Llegada])

Total Departures =
SUM(Fact_TraficoAereo[Vuelos_Salida])

# Rankings

Airport Rank =
RANKX(
    ALL(Dim_Aeropuerto[Aeropuerto]),
    [Total Flights],
    ,
    DESC,
    DENSE
)

Country Rank =
RANKX(
    ALL(Dim_Pais[Pais]),
    [Total Flights],
    ,
    DESC,
    DENSE
)

Top Airport =
MAXX(
    TOPN(
        1,
        ALL(Dim_Aeropuerto[Aeropuerto]),
        [Total Flights],
        DESC
    ),
    Dim_Aeropuerto[Aeropuerto]
)

Top Airport Flights =
MAXX(
    TOPN(
        1,
        ALL(Dim_Aeropuerto[Aeropuerto]),
        [Total Flights],
        DESC
    ),
    [Total Flights]
)

# Growth Opportunities

Crecimiento sostenido promedio entre 2018 y 2019 para aeropuertos elegibles.

El crecimiento se calcula como el promedio de:

Crecimiento 2018 sobre 2017.
Crecimiento 2019 sobre 2018.

Airport Growth % =
VAR CurrentAirport =
    SELECTEDVALUE(Dim_Aeropuerto[ICAO_Aeropuerto])

VAR TotalAirportFlights =
    CALCULATE(
        [Total Flights],
        ALL(Dim_Fecha)
    )

VAR Flights2017 =
    CALCULATE(
        [Total Flights],
        ALL(Dim_Fecha),
        Dim_Fecha[Año] = 2017
    )

VAR Flights2018 =
    CALCULATE(
        [Total Flights],
        ALL(Dim_Fecha),
        Dim_Fecha[Año] = 2018
    )

VAR Flights2019 =
    CALCULATE(
        [Total Flights],
        ALL(Dim_Fecha),
        Dim_Fecha[Año] = 2019
    )

RETURN
IF(
    CurrentAirport IN {"LTFM", "LLBG"}
        || TotalAirportFlights <= 200000
        || Flights2017 < 10000
        || Flights2018 < 10000
        || Flights2019 < 10000,
    BLANK(),
    DIVIDE(
        DIVIDE(
            Flights2018 - Flights2017,
            Flights2017
        )
            +
        DIVIDE(
            Flights2019 - Flights2018,
            Flights2018
        ),
        2
    )
)

Máximo crecimiento observado entre los aeropuertos elegibles.

Max Growth =
MAXX(
    FILTER(
        ALL(Dim_Aeropuerto),
        NOT ISBLANK([Airport Growth %])
    ),
    [Airport Growth %]
)

Normalización del crecimiento sostenido respecto al máximo crecimiento observado entre los aeropuertos elegibles.

Growth Score =
VAR AirportsWithGrowth =
    ADDCOLUMNS(
        ALL(Dim_Aeropuerto),
        "Growth", [Airport Growth %],
        "Flights",
            CALCULATE(
                [Total Flights],
                ALL(Dim_Fecha)
            )
    )

VAR MaxGrowth =
    MAXX(
        FILTER(
            AirportsWithGrowth,
            [Flights] > 200000
                && Dim_Aeropuerto[ICAO_Aeropuerto] <> "LTFM"
                && Dim_Aeropuerto[ICAO_Aeropuerto] <> "LLBG"
                && NOT ISBLANK([Growth])
        ),
        [Growth]
    )

RETURN
DIVIDE(
    [Airport Growth %],
    MaxGrowth
)

# Growth Opportunities

Indicador compuesto de oportunidad estratégica.

El COS combina:

Market Share Normalized: peso relativo del mercado.
Growth Score: crecimiento relativo del aeropuerto.

Ambos componentes tienen una ponderación equivalente del 50 %.

COS =
VAR MS = [Market Share Normalized]
VAR GS = [Growth Score]

RETURN
IF(
    ISBLANK(GS),
    BLANK(),
    0.50 * MS + 0.50 * GS
)

Average COS =
AVERAGEX(
    ALL(Dim_Aeropuerto),
    [COS]
)

COS Rank =
RANKX(
    ALL(Dim_Aeropuerto),
    [COS],
    ,
    DESC,
    DENSE
)

Top Opportunity Airport =
VAR TopAirport =
    TOPN(
        1,
        FILTER(
            ALL(Dim_Aeropuerto),
            NOT ISBLANK([COS])
        ),
        [COS],
        DESC
    )

RETURN
MAXX(
    TopAirport,
    Dim_Aeropuerto[Aeropuerto]
)

Top Growth Airport =
MAXX(
    TOPN(
        1,
        FILTER(
            ALL(Dim_Aeropuerto),
            NOT ISBLANK([Airport Growth %])
        ),
        [Airport Growth %],
        DESC
    ),
    Dim_Aeropuerto[Aeropuerto]
)

# Supporting Measures

Max Flights =
MAXX(
    ALL(Dim_Aeropuerto),
    [Total Flights]
)

# Consideraciones metodológicas

Las medidas correspondientes al componente Growth Opportunities implementan los criterios metodológicos definidos en la Sección 4.5 del documento principal.

En particular:

El crecimiento se calcula como el promedio del crecimiento interanual 2018 sobre 2017 y 2019 sobre 2018.
Se excluyen LTFM (Istanbul Airport) y LLBG (Tel Aviv – Ben Gurion).
Solo participan aeropuertos con más de 200.000 vuelos totales.
Se exige un mínimo de 10.000 vuelos en cada uno de los años utilizados para el cálculo.
Estos criterios permiten evitar distorsiones derivadas de series históricas incompletas o bases extremadamente reducidas.

Estos criterios permiten que el Congestion Opportunity Score (COS) represente una medida robusta del potencial comercial relativo de los principales mercados aeroportuarios europeos.
