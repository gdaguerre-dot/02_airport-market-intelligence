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

