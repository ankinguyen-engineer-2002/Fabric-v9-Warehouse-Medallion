# 30 — Gold Layer

> Scanned: 2026-05-06 · Updated 2026-05-10 post Bob alignment (view prefix `vw_*` → `v_*`; schema `_DW` ALL CAPS unchanged).
> **Warehouse:** `SupplyChain_Gold_Warehouse` (`98e2a911-5af9-442e-9cc8-5d8dadb8b762`)
> **Schema:** `ForecastAccuracy_DW`
> **Role:** Dedicated serving boundary for Direct Lake semantic model.

## Summary

| Type | Count | Total rows |
|------|------:|-----------:|
| Fact tables | 2 | 83,506,809 |
| Dimension tables | 5 | 437,536 |
| Views (1-to-1 with tables) | 7 | — |

> ETL DDL for all 7 Gold views: see [`etl/gold_views.sql`](etl/gold_views.sql).

---

## Fact Tables

### `FactForecastActual` — 47,105,693 rows

UNION ALL of 3 demand sources into a unified fact for forecast accuracy reporting.

| Column | Type | Source / Logic |
|--------|------|---------------|
| `ItemSKU` | VARCHAR | from each source |
| `WarehouseCode` | VARCHAR | from each source |
| `CustomerGroupCode` | VARCHAR | from each source |
| `FSCMonthFirst` | DATE | from each source |
| `FSCMonthLast` | DATE | from each source |
| `HorizonCode` | VARCHAR(20) | `'Actual demand'` (literal) / `HorizonCode` (forecast) / `'Naive forecast'` (literal) |
| `StatusCode` | VARCHAR | from each source |
| `VersionName` | VARCHAR | `VersionName` (actual) / `VersionCode` (forecast) / `VersionName` (naive) |
| `Qty` | FLOAT | `CAST(QtyDemand AS FLOAT)` (actual) / `CAST(QtyForecast AS FLOAT)` (forecast) / `CAST(QtyDemand AS FLOAT)` (naive) |
| `LoadDT` | DATETIME2(6) | `CAST(GETUTCDATE() AS DATETIME2(6))` |

**Source SQL:**
```sql
CREATE VIEW ForecastAccuracy_DW.v_FactForecastActual AS
SELECT ItemSKU, WarehouseCode, CustomerGroupCode, FSCMonthFirst, FSCMonthLast,
       CAST('Actual demand' AS VARCHAR(20)) AS HorizonCode, StatusCode, VersionName,
       CAST(QtyDemand AS FLOAT) AS Qty,
       CAST(GETUTCDATE() AS DATETIME2(6)) AS LoadDT
FROM SupplyChain_Processing_Warehouse.SalesHistory_Enh.ActualDemandMonthly
UNION ALL
SELECT ItemSKU, WarehouseCode, CustomerGroupCode, FSCMonthFirst, FSCMonthLast,
       HorizonCode, StatusCode, VersionCode, CAST(QtyForecast AS FLOAT),
       CAST(GETUTCDATE() AS DATETIME2(6))
FROM SupplyChain_Processing_Warehouse.ForecastHistory_Enh.ForecastDemandMonthly
UNION ALL
SELECT ItemSKU, WarehouseCode, CustomerGroupCode, FSCMonthFirst, FSCMonthLast,
       CAST('Naive forecast' AS VARCHAR(20)), StatusCode, VersionName,
       CAST(QtyDemand AS FLOAT),
       CAST(GETUTCDATE() AS DATETIME2(6))
FROM SupplyChain_Processing_Warehouse.ForecastHistory_Enh.NaiveForecastMonthly;
```

### `FactForecastKpi` — 36,401,116 rows

Computed KPI fact derived from joining `FactForecastActual` against itself (Forecast vs Actual) with horizon spine + 7 derived error metrics.

**Derived KPI columns (7 added vs v8):**
- `QtyNaiveFcstError` — naive forecast error
- `QtyAbsNaiveFcstError` — absolute naive error
- `QtySquaredFcstError` — squared error
- `QtySquaredNaiveFcstError` — squared naive error
- `ValidObsFlag` — flag for valid observation (forecast + actual both present)
- `ValidActualNonzeroFlag` — flag for non-zero actual demand
- `AbsPctError` — absolute percent error (MAPE component)

Spine joins via CROSS JOIN to `DimForecastHorizon` for monthly horizon expansion.

> Full DDL: [`etl/gold_views.sql`](etl/gold_views.sql) — search for `v_FactForecastKpi`.

---

## Dimension Tables

| Table | Rows | Cols | Source (cross-DB from Processing WH) | Notes |
|-------|-----:|-----:|--------------------------------------|-------|
| `DimCalendar` | 21,551 | — | `ReferenceMaster_Enh.Calendar` | 74 cols total (extended +64 vs v8) |
| `DimCustomerGrouping` | 35,617 | — | `ReferenceMaster_Enh.CustomerGrouping` | Customer group mapping |
| `DimForecastHorizon` | 8 | — | `ReferenceMaster_Enh.ForecastHorizon` | +`Rank` col for sort order vs v8 |
| `DimProduct` | 379,305 | — | `Staging_Wrk.ProductEdw` | 32 cols (full Product master) |
| `DimWarehouse` | 55 | — | `ReferenceMaster_Enh.Warehouse` | Warehouse master |

**Pattern (all dims):**
```sql
CREATE VIEW ForecastAccuracy_DW.v_Dim<Entity> AS
SELECT *, CAST(GETUTCDATE() AS DATETIME2(6)) AS LoadDT
FROM SupplyChain_Processing_Warehouse.<Schema>.<Table>;
```

---

## Gold Refresh Pipeline

`pl_sc_gold` (`50ff6263-659d-4b09-9e45-b42a3434e093`):
- Reads `Meta.AssetRegistry` for `canonical_layer = 'Gold'` AND `is_active = 1`
- ForEach Gold asset → dynamic `DROP TABLE IF EXISTS` + `CREATE TABLE AS SELECT * FROM <view>`
- Cross-DB write via Pipeline (SP cannot write across WH)

Each Gold asset declared in registry as:

```sql
INSERT INTO Meta.AssetRegistry (
    asset_id, canonical_layer, access_mode,
    physical_schema, physical_object, load_type, frequency, cron_expression,
    project, is_active, source_objects, legacy_view_name
) VALUES (
    'gold::FactForecastActual', 'Gold', 'GoldPublish',
    'ForecastAccuracy_DW', 'FactForecastActual', 'overwrite', 'daily', '0 2 * * *',
    'forecast', 1,
    '["SalesHistory_Enh.ActualDemandMonthly","ForecastHistory_Enh.ForecastDemandMonthly","ForecastHistory_Enh.NaiveForecastMonthly"]',
    'ForecastAccuracy_DW.v_FactForecastActual'
);
```

---

## Direct Lake Semantic Source

The semantic model `sc_forecast_control_tower` reads physical tables (NOT views) via Direct Lake mode. See [50_semantic.md](50_semantic.md) for model details.

7 Direct Lake edges live in `Meta.LineageEdge`:
- `ForecastAccuracy_DW.{DimCalendar | DimCustomerGrouping | DimForecastHorizon | DimProduct | DimWarehouse | FactForecastActual | FactForecastKpi}` → `SemanticModel.sc_forecast_control_tower` (edge_type = `directLake`)
