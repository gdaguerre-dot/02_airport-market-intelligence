# DAX Measure Catalog

Los nombres de columna referenciados (`Vuelos_Totales`, `Vuelos_Llegada`, `Vuelos_Salida`, `ICAO_Aeropuerto`, `Pais`) corresponden a los nombres finales tras el proceso de renombrado documentado en `power_query_m.md`.

---

## Índice por categoría

| Categoría | Medidas |
|---|---|
| KPIs | Total Flights, Total Countries, Total Airports |
| Market Analysis | Market Share %, Airport Market Share %, Market Share Normalized |
| Time Intelligence | Flights Previous Year, YoY Growth %, Flights 2019 Comparable, Recovery vs 2019 % |
| Operations | Total Arrivals, Total Departures |
| Rankings | Airport Rank, Country Rank, Top Airport, Top Airport Flights |
| Growth Opportunities | Airport Growth %, Max Growth, Growth Score, Congestion Opportunity Score (COS), COS Rank, Top Opportunity Airport, Top Growth Airport |
| Supporting | Max Flights, Average COS |

---

## 1. KPIs

### Total Flights
```dax
Total Flights =
SUM(Fact_TraficoAereo[Vuelos_Totales])
```
Métrica base del proyecto. Representa la escala operativa de cada aeropuerto/país bajo el contexto de filtro activo.

### Total Countries
```dax
Total Countries =
DISTINCTCOUNT(Dim_Pais[Pais])
```

### Total Airports
```dax
Total Airports =
DISTINCTCOUNT(Dim_Aeropuerto[ICAO_Aeropuerto])
```

---

## 2. Market Analysis

### Market Share %
```dax
Market Share % =
DIVIDE(
    [Total Flights],
    CALCULATE(
        [Total Flights],
        ALL(Dim_Pais)
    )
)
```
Participación de un país (o de la selección activa) sobre el total del mercado europeo, eliminando el contexto de filtro geográfico mediante `ALL(Dim_Pais)`.

### Airport Market Share %
```dax
Airport Market Share % =
DIVIDE(
    [Total Flights],
    CALCULATE(
        [Total Flights],
        ALL(Dim_Aeropuerto)
    )
)
```
Misma lógica aplicada a nivel aeropuerto individual.

### Market Share Normalized
```dax
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
```
Reescala la participación de mercado a un rango [0,1] usando el aeropuerto con mayor participación como referencia. Esta normalización es la que evita que los grandes hubs dominen automáticamente el componente de escala del COS.

---

## 3. Time Intelligence

### Flights Previous Year
```dax
Flights Previous Year =
CALCULATE(
    [Total Flights],
    SAMEPERIODLASTYEAR(Dim_Fecha[Fecha])
)
```

### YoY Growth %
```dax
YoY Growth % =
DIVIDE(
    [Total Flights] - [Flights Previous Year],
    [Flights Previous Year]
)
```
Medida de crecimiento interanual de propósito general (contexto de filtro dinámico), distinta de `Airport Growth %`, que está fijada a 2017–2019 para el cálculo del COS.

### Flights 2019 Comparable
```dax
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
```
Construye un período de comparación homogéneo: si el contexto activo es 2022 (que solo cubre enero–mayo en el dataset), compara contra enero–mayo de 2019 en lugar del año completo. Esto es lo que hace metodológicamente válido al Recovery Rate.

### Recovery vs 2019 %
```dax
Recovery vs 2019 % =
DIVIDE(
    [Total Flights],
    [Flights 2019 Comparable]
)
```

---

## 4. Operations

### Total Arrivals
```dax
Total Arrivals =
SUM(Fact_TraficoAereo[Vuelos_Llegada])
```

### Total Departures
```dax
Total Departures =
SUM(Fact_TraficoAereo[Vuelos_Salida])
```

---

## 5. Rankings

### Airport Rank
```dax
Airport Rank =
RANKX(
    ALL(Dim_Aeropuerto[Aeropuerto]),
    [Total Flights],
    ,
    DESC,
    DENSE
)
```

### Country Rank
```dax
Country Rank =
RANKX(
    ALL(Dim_Pais[Pais]),
    [Total Flights],
    ,
    DESC,
    DENSE
)
```

### Top Airport
```dax
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
```

### Top Airport Flights
```dax
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
```

---

## 6. Growth Opportunities — núcleo metodológico del proyecto

### Airport Growth %
> Crecimiento sostenido promedio entre 2017–2018 y 2018–2019, para aeropuertos elegibles.

```dax
Airport Growth % =
VAR CurrentAirport =
    SELECTEDVALUE(Dim_Aeropuerto[ICAO_Aeropuerto])
VAR TotalAirportFlights =
    CALCULATE([Total Flights], ALL(Dim_Fecha))
VAR Flights2017 =
    CALCULATE([Total Flights], ALL(Dim_Fecha), Dim_Fecha[Año] = 2017)
VAR Flights2018 =
    CALCULATE([Total Flights], ALL(Dim_Fecha), Dim_Fecha[Año] = 2018)
VAR Flights2019 =
    CALCULATE([Total Flights], ALL(Dim_Fecha), Dim_Fecha[Año] = 2019)
RETURN
IF(
    CurrentAirport IN {"LTFM", "LLBG"}
        || TotalAirportFlights <= 200000
        || Flights2017 < 10000
        || Flights2018 < 10000
        || Flights2019 < 10000,
    BLANK(),
    DIVIDE(
        DIVIDE(Flights2018 - Flights2017, Flights2017)
            + DIVIDE(Flights2019 - Flights2018, Flights2018),
        2
    )
)
```

**Criterios de elegibilidad codificados directamente en la medida:**
- Exclusión explícita de `LTFM` (iGA Istanbul) — cambio estructural de infraestructura, no crecimiento de demanda.
- Exclusión explícita de `LLBG` (Tel Aviv – Ben Gurion).
- Más de 200.000 vuelos totales en el período.
- Al menos 10.000 vuelos en cada uno de 2017, 2018 y 2019.
- Si no se cumplen todas las condiciones → `BLANK()`, no cero. Esto es importante: un aeropuerto no elegible queda fuera del ranking de crecimiento en lugar de aparecer con 0%, que lo penalizaría incorrectamente.

> ⚠️ **Nota de consistencia interna:** `LLBG` está excluido aquí por regla explícita, aun cuando el problema de nomenclatura de `LLBG` (dos descripciones para el mismo ICAO) ya fue corregido en Power Query (ver `power_query_m.md`). Vale la pena documentar en el case study *por qué* la exclusión se mantiene después del fix de nomenclatura — por ejemplo, si Tel Aviv presenta además una discontinuidad de series históricas independiente del problema de nombre — para que un lector técnico no interprete esto como una regla obsoleta.

### Max Growth
```dax
Max Growth =
MAXX(
    FILTER(
        ALL(Dim_Aeropuerto),
        NOT ISBLANK([Airport Growth %])
    ),
    [Airport Growth %]
)
```

### Growth Score
> Normalización del crecimiento sostenido.

```dax
Growth Score =
VAR AirportsWithGrowth =
    ADDCOLUMNS(
        ALL(Dim_Aeropuerto),
        "Growth", [Airport Growth %],
        "Flights", CALCULATE([Total Flights], ALL(Dim_Fecha))
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
DIVIDE([Airport Growth %], MaxGrowth)
```
El máximo de referencia para la normalización se recalcula sobre el mismo universo elegible, evitando que un aeropuerto excluido (aunque nunca debería tener `Airport Growth %` no-blank) contamine el denominador.

### Congestion Opportunity Score (COS)
> Indicador compuesto de oportunidad estratégica.

```dax
COS =
VAR MS = [Market Share Normalized]
VAR GS = [Growth Score]
RETURN
IF(
    ISBLANK(GS),
    BLANK(),
    0.50 * MS + 0.50 * GS
)
```
Un aeropuerto sin `Growth Score` (es decir, no elegible) no recibe COS. No se le asigna 0 — queda fuera del ranking en lugar de ser penalizado, que sería una decisión analítica distinta y no la que el proyecto adoptó.

### COS Rank
```dax
COS Rank =
RANKX(
    ALL(Dim_Aeropuerto),
    [COS],
    ,
    DESC,
    DENSE
)
```

### Top Opportunity Airport
```dax
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
```

### Top Growth Airport
```dax
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
```

---

## 7. Supporting Measures

### Max Flights
```dax
Max Flights =
MAXX(
    ALL(Dim_Aeropuerto),
    [Total Flights]
)
```

### Average COS
```dax
Average COS =
AVERAGEX(
    ALL(Dim_Aeropuerto),
    [COS]
)
```

---

## Consideraciones metodológicas

Las medidas del bloque **Growth Opportunities** implementan directamente los criterios definidos durante la etapa de validación metodológica del proyecto:

- El crecimiento se calcula como el **promedio del crecimiento interanual 2017→2018 y 2018→2019** (no como CAGR 2016–2021, que fue la versión inicial descartada).
- Se excluyen explícitamente `LTFM` (iGA Istanbul Airport) y `LLBG` (Tel Aviv – Ben Gurion) del componente de crecimiento.
- Solo participan aeropuertos con **más de 200.000 vuelos totales** en el período.
- Se exige un **mínimo de 10.000 vuelos** en cada uno de los años utilizados para el cálculo, evitando distorsiones derivadas de series históricas incompletas o bases extremadamente reducidas.

Estos criterios permiten que el Congestion Opportunity Score (COS) represente una medida robusta del potencial comercial relativo de los principales mercados aeroportuarios europeos, y que el resultado sea reproducible: cualquier persona que abra el modelo puede ver exactamente qué aeropuertos entraron al cálculo y por qué regla.

