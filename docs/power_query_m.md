# Power Query (M) — ETL Documentation

**Proyecto:** Airport Market Intelligence

**Motor de origen:** SQL Server (`AirportMarketDB`, tabla `dbo.flights_Raw`)

**Autor:** Gerónimo Daguerre

Este documento describe las consultas de Power Query que transforman la capa Raw (SQL Server) en el modelo dimensional (Star Schema) consumido por el dashboard. El orden de lectura sigue la dependencia real entre consultas: `Flights_Raw → Flights_Clean → {Dim_Pais, Dim_Aeropuerto, Dim_Fecha} → Fact_TraficoAereo`.

---

## Mapa de dependencias

```
Flights_Raw (SQL Server)
      ↓
Flights_Clean (tipificación + estandarización de nombres)
      ↓
      ├── Dim_Pais
      ├── Dim_Aeropuerto  (referencia Dim_Pais)
      ├── Dim_Fecha        (referencia Flights_Raw directamente)
      └── Fact_TraficoAereo (referencia Flights_Clean + Dim_Aeropuerto)
```

---

## 1. Flights_Raw

Conexión directa a la capa Raw en SQL Server.

```m
let
    Origen = Sql.Database("localhost\SQLEXPRESS", "AirportMarketDB"),
    dbo_flights_Raw = Origen{[Schema="dbo",Item="flights_Raw"]}[Data]
in
    dbo_flights_Raw
```

---

## 2. Flights_Clean

Tipifica columnas y corrige la inconsistencia de nomenclatura detectada en `APT_NAME` para el aeropuerto de Tel Aviv (ver `03_data_quality_assessment.sql`).

```m
let
    Origen = Flights_Raw,
    #"Tipos de datos establecidos" = Table.TransformColumnTypes(Origen,{{"FLT_DATE", type datetime}, {"FLT_DEP_1", Int64.Type}, {"FLT_ARR_1", Int64.Type}, {"FLT_TOT_1", Int64.Type}}),
    #"Fecha convertida a solo fecha" = Table.TransformColumns(#"Tipos de datos establecidos",{{"FLT_DATE", DateTime.Date, type date}}),
    #"Valor reemplazado" = Table.ReplaceValue(#"Fecha convertida a solo fecha","Ben Gurion International","Tel Aviv - Ben Gurion International",Replacer.ReplaceText,{"APT_NAME"}),
    #"Filas filtradas" = Table.SelectRows(#"Valor reemplazado", each true),
    #"Valor reemplazado1" = Table.ReplaceValue(#"Filas filtradas","Tel Aviv - Tel Aviv - Ben Gurion International","Tel Aviv - Ben Gurion International",Replacer.ReplaceText,{"APT_NAME"}),
    #"Filas filtradas1" = Table.SelectRows(#"Valor reemplazado1", each true)
in
    #"Filas filtradas1"
```

**Qué hace cada paso:**
1. Tipifica `FLT_DATE` como datetime y las columnas de vuelos como enteros.
2. Convierte `FLT_DATE` de datetime a date puro.
3. Reemplaza el texto `"Ben Gurion International"` por `"Tel Aviv - Ben Gurion International"` en `APT_NAME`, resolviendo la inconsistencia de nomenclatura documentada en el proceso de Data Quality.
4. `Filas filtradas` — filtro `each true`, es decir, no filtra nada.
5. Un segundo `ReplaceValue` corrige `"Tel Aviv - Tel Aviv - Ben Gurion International"` → `"Tel Aviv - Ben Gurion International"`.
6. `Filas filtradas1` — otro filtro `each true`.

> ```m
> #"Nombre estandarizado" = Table.ReplaceValue(
>     #"Fecha convertida a solo fecha",
>     "Ben Gurion International",
>     "Tel Aviv - Ben Gurion International",
>     Replacer.ReplaceText,
>     {"APT_NAME"}
> )
> ```

---

## 3. Dim_Pais

Dimensión de país: valores únicos de `STATE_NAME`, ordenados alfabéticamente y con clave surrogate (`Pais_ID`) generada por índice.

```m
let
    Origen = Flights_Clean,
    Seleccion_Columna_Pais = Table.SelectColumns(Origen,{"STATE_NAME"}),
    Paises_Unicos = Table.Distinct(Seleccion_Columna_Pais),
    Orden_Paises = Table.Sort(Paises_Unicos,{{"STATE_NAME", Order.Ascending}}),
    Creacion_Pais_ID = Table.AddIndexColumn(Orden_Paises, "Índice", 1, 1, Int64.Type),
    Renombrado_Columna_Pais = Table.RenameColumns(Creacion_Pais_ID,{{"Índice", "Pais_ID"}, {"STATE_NAME", "Pais"}}),
    Reordenado_Columnas_Dim_Pais = Table.ReorderColumns(Renombrado_Columna_Pais,{"Pais_ID", "Pais"})
in
    Reordenado_Columnas_Dim_Pais
```

Columnas finales: `Pais_ID`, `Pais`.

---

## 4. Dim_Aeropuerto

Dimensión de aeropuerto. Referencia `Flights_Clean` (ya con el nombre de Tel Aviv corregido) y `Dim_Pais` para incorporar la clave surrogate del país.

```m
let
    Origen = Flights_Clean,
    Seleccion_Columnas_Aeropuerto = Table.SelectColumns(Origen,{"APT_ICAO", "APT_NAME", "STATE_NAME"}),
    Nombre_Estandarizado = Table.TransformColumns(
        Seleccion_Columnas_Aeropuerto,
        {{"APT_NAME", each if _ = "Ben Gurion International" then "Tel Aviv - Ben Gurion International" else _, type text}}
    ),
    Aeropuertos_Unicos = Table.Distinct(Nombre_Estandarizado),
    Renombrado_Columnas_Aeropuerto = Table.RenameColumns(Aeropuertos_Unicos,{{"APT_ICAO", "ICAO_Aeropuerto"}, {"APT_NAME", "Aeropuerto"}, {"STATE_NAME", "Pais"}}),
    Incorporacion_Pais_ID = Table.NestedJoin(Renombrado_Columnas_Aeropuerto, {"Pais"}, Dim_Pais, {"Pais"}, "Dim_Pais", JoinKind.LeftOuter),
    Incorporacion_Clave_Pais = Table.ExpandTableColumn(Incorporacion_Pais_ID, "Dim_Pais", {"Pais_ID"}, {"Pais_ID"}),
    Estructura_Final_Dim_Aeropuerto = Table.ReorderColumns(Incorporacion_Clave_Pais,{"ICAO_Aeropuerto", "Aeropuerto", "Pais_ID", "Pais"})
in
    Estructura_Final_Dim_Aeropuerto
```

> **Nota de redundancia:** el paso `Nombre_Estandarizado` vuelve a aplicar la corrección de "Ben Gurion International" sobre datos que ya vienen de `Flights_Clean` (que ya la aplicó). Como esta versión usa comparación exacta (`if _ = "Ben Gurion International"`, no substring), no genera el efecto de doble reemplazo del punto anterior — simplemente no encuentra coincidencias y no hace nada. Es lógica duplicada pero inofensiva; se podría eliminar este paso y usar `Aeropuertos_Unicos = Table.Distinct(Seleccion_Columnas_Aeropuerto)` directamente.

Columnas finales: `ICAO_Aeropuerto`, `Aeropuerto`, `Pais_ID`, `Pais`.

---

## 5. Dim_Fecha

Dimensión de tiempo con jerarquía completa (día, semana, mes, trimestre, año). Se construye a partir de `Flights_Raw` directamente (no de `Flights_Clean`), tomando solo las fechas distintas presentes en el dataset.

```m
let
    Origen = Flights_Raw,
    #"Columnas seleccionadas" = Table.SelectColumns(Origen,{"YEAR", "MONTH_NUM", "MONTH_MON", "FLT_DATE"}),
    #"Fechas únicas" = Table.Distinct(#"Columnas seleccionadas"),
    #"Fechas ordenadas" = Table.Sort(#"Fechas únicas",{{"FLT_DATE", Order.Ascending}}),
    Extraccion_Numero_Mes = Table.TransformColumns(#"Fechas ordenadas", {{"FLT_DATE", each Text.Start(_, 10), type text}}),
    Tipificacion_Datos = Table.TransformColumnTypes(Extraccion_Numero_Mes,{{"FLT_DATE", type date}}),
    Renombrado_Columnas = Table.RenameColumns(Tipificacion_Datos,{{"FLT_DATE", "Fecha"}}),
    Creacion_Año = Table.AddColumn(Renombrado_Columnas, "Año", each Date.Year([Fecha]), Int64.Type),
    Creacion_Mes_Numero = Table.AddColumn(Creacion_Año, "Mes", each Date.Month([Fecha]), Int64.Type),
    Renombrado_Columnas2 = Table.RenameColumns(Creacion_Mes_Numero,{{"Mes", "Mes_Numero"}}),
    Creacion_Mes_Nombre = Table.AddColumn(Renombrado_Columnas2, "Nombre del mes", each Date.MonthName([Fecha]), type text),
    Renombrado_Columnas3 = Table.RenameColumns(Creacion_Mes_Nombre,{{"Nombre del mes", "Mes_Nombre"}}),
    Creacion_Trimestre = Table.AddColumn(Renombrado_Columnas3, "Trimestre", each Date.QuarterOfYear([Fecha]), Int64.Type),
    Creacion_Año_Mes = Table.AddColumn(Creacion_Trimestre, "Año_Mes", each Text.From([Año]) & "-" & Text.PadStart(Text.From([Mes_Numero]),2,"0")),
    Creacion_Dia = Table.AddColumn(Creacion_Año_Mes, "Día", each Date.Day([Fecha]), Int64.Type),
    Creacion_Dia_Semana_Numero = Table.AddColumn(Creacion_Dia, "Día de la semana", each Date.DayOfWeek([Fecha]), Int64.Type),
    Renombrado_Columnas4 = Table.RenameColumns(Creacion_Dia_Semana_Numero,{{"Día de la semana", "Día_Semana_Numero"}}),
    Creacion_Dia_Semana_Nombre = Table.AddColumn(Renombrado_Columnas4, "Nombre del día", each Date.DayOfWeekName([Fecha]), type text),
    Renombrado_Columnas5 = Table.RenameColumns(Creacion_Dia_Semana_Nombre,{{"Nombre del día", "Día_Semana_Nombre"}}),
    Creacion_Semana_Año = Table.AddColumn(Renombrado_Columnas5, "Semana del año", each Date.WeekOfYear([Fecha]), Int64.Type),
    Renombrado_Columnas6 = Table.RenameColumns(Creacion_Semana_Año,{{"Semana del año", "Semana_Año"}}),
    Tipificacion_Año_Mes = Table.TransformColumnTypes(Renombrado_Columnas6,{{"Año_Mes", type text}})
in
    Tipificacion_Año_Mes
```

Columnas finales: `Fecha`, `Año`, `Mes_Numero`, `Mes_Nombre`, `Trimestre`, `Año_Mes`, `Día`, `Día_Semana_Numero`, `Día_Semana_Nombre`, `Semana_Año`.

> **Nota menor:** el paso `Extraccion_Numero_Mes` (nombre heredado de una etapa anterior de la consulta) en realidad recorta el texto de `FLT_DATE` a 10 caracteres antes de tipificarlo como fecha — no extrae el número de mes. El nombre del paso no describe lo que hace; es solo un tema de legibilidad del código, no afecta el resultado.

---

## 6. Fact_TraficoAereo

Tabla de hechos. Grano: **1 registro = 1 aeropuerto × 1 día**. Referencia `Flights_Clean` para las métricas y `Dim_Aeropuerto` para incorporar la clave de país.

```m
let
    Origen = Flights_Clean,
    Preparacion_Fact_TraficoAereo = Table.SelectColumns(Origen,{"FLT_DATE", "APT_ICAO", "FLT_DEP_1", "FLT_ARR_1", "FLT_TOT_1", "FLT_DEP_IFR_2", "FLT_ARR_IFR_2", "FLT_TOT_IFR_2"}),
    Renombrado_Columnas_Fact = Table.RenameColumns(Preparacion_Fact_TraficoAereo,{{"FLT_DATE", "Fecha"}, {"APT_ICAO", "ICAO_Aeropuerto"}, {"FLT_DEP_1", "Vuelos_Salida"}, {"FLT_ARR_1", "Vuelos_Llegada"}, {"FLT_TOT_1", "Vuelos_Totales"}, {"FLT_DEP_IFR_2", "Salidas_IFR"}, {"FLT_ARR_IFR_2", "Llegadas_IFR"}, {"FLT_TOT_IFR_2", "Total_IFR"}}),
    Incorporacion_Pais_ID = Table.NestedJoin(Renombrado_Columnas_Fact, {"ICAO_Aeropuerto"}, Dim_Aeropuerto, {"ICAO_Aeropuerto"}, "Dim_Aeropuerto", JoinKind.LeftOuter),
    Incorporacion_Clave_Pais = Table.ExpandTableColumn(Incorporacion_Pais_ID, "Dim_Aeropuerto", {"Pais_ID"}, {"Pais_ID"}),
    Estructura_Final_Fact = Table.ReorderColumns(Incorporacion_Clave_Pais,{"Fecha", "ICAO_Aeropuerto", "Pais_ID", "Vuelos_Salida", "Vuelos_Llegada", "Vuelos_Totales", "Salidas_IFR", "Llegadas_IFR", "Total_IFR"})
in
    Estructura_Final_Fact
```

Columnas finales: `Fecha`, `ICAO_Aeropuerto`, `Pais_ID`, `Vuelos_Salida`, `Vuelos_Llegada`, `Vuelos_Totales`, `Salidas_IFR`, `Llegadas_IFR`, `Total_IFR`.

Las columnas IFR se conservan en la tabla de hechos (por completitud del dato) aunque quedaron excluidas de los KPIs e indicadores estratégicos por su baja completitud (~70% de valores nulos), tal como se documentó en `03_data_quality_assessment.sql`.

---

## Correspondencia de nombres: SQL → Power Query

| Columna origen (SQL) | Columna final (modelo) | Tabla |
|---|---|---|
| `FLT_DATE` | `Fecha` | Fact_TraficoAereo / Dim_Fecha |
| `APT_ICAO` | `ICAO_Aeropuerto` | Dim_Aeropuerto / Fact_TraficoAereo |
| `APT_NAME` | `Aeropuerto` | Dim_Aeropuerto |
| `STATE_NAME` | `Pais` | Dim_Pais / Dim_Aeropuerto |
| `FLT_DEP_1` | `Vuelos_Salida` | Fact_TraficoAereo |
| `FLT_ARR_1` | `Vuelos_Llegada` | Fact_TraficoAereo |
| `FLT_TOT_1` | `Vuelos_Totales` | Fact_TraficoAereo |
| `FLT_DEP_IFR_2` | `Salidas_IFR` | Fact_TraficoAereo |
| `FLT_ARR_IFR_2` | `Llegadas_IFR` | Fact_TraficoAereo |
| `FLT_TOT_IFR_2` | `Total_IFR` | Fact_TraficoAereo |
