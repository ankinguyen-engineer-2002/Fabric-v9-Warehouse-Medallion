# forecast — Forecast Accuracy Mart

> **Status:** LIVE · **Gold schema:** `ForecastAccuracy_DW` · **Last scan:** 2026-05-06

## What

End-to-end Forecast Accuracy analytics mart on Microsoft Fabric. Combines actual sales demand, forecast demand, and naive forecast into a unified Gold serving layer for Power BI Direct Lake reporting via the `sc_forecast_control_tower` semantic model.

## Live infrastructure snapshot

| Item | Value |
|------|-------|
| Workspace DEV | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| Processing WH | `c0262cef-b8a7-495f-bccc-53b098c7948c` |
| Gold WH | `98e2a911-5af9-442e-9cc8-5d8dadb8b762` |
| SQL Endpoint | `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com` |
| Schemas | 6 (Staging_WRK, ReferenceMaster_ENH, SalesHistory_ENH, ForecastHistory_ENH, OpenOrderHistory_ENH, Meta) |
| Total tables | 49 (42 Processing + 7 Gold) |
| Total views | 35 (28 Processing + 7 Gold) |
| Total SPs / functions | 18 (14 SPs + 3 scalar functions in Meta + 1 SP in Staging_WRK) |
| Registry assets | 33 |
| Lineage edges | 60 |
| DQ rules | 54 |
| DAG waves | 3 (Wave 0 / Wave 1 / Wave 2) |
| Pipelines | 7 |
| Semantic model | `sc_forecast_control_tower` (`f06a2361-15fd-4f91-9d37-941fefe62aaf`) |

## Live row counts

### Processing WH (Silver)

| Schema | Total rows |
|--------|-----------:|
| `Staging_WRK` | 156,120,911 |
| `ReferenceMaster_ENH` | 637,360 |
| `SalesHistory_ENH` | 136,442,343 |
| `ForecastHistory_ENH` | 44,454,578 |
| `OpenOrderHistory_ENH` | 269,015 |

### Gold WH (`ForecastAccuracy_DW`)

| Type | Rows |
|------|-----:|
| Fact (2 tables) | 83,506,809 |
| Dim (5 tables) | 437,536 |

**Grand total:** ~421M rows across both warehouses.

## Quick links

| Section | Doc |
|---------|-----|
| Workspace + IDs | [00_workspace.md](00_workspace.md) |
| Bronze layer | [10_bronze.md](10_bronze.md) |
| Silver layer (per schema) | [20_silver.md](20_silver.md) |
| Gold layer | [30_gold.md](30_gold.md) |
| Pipelines (IDs + DAG) | [40_pipelines.md](40_pipelines.md) |
| Semantic model | [50_semantic.md](50_semantic.md) |
| Lineage | [60_lineage.md](60_lineage.md) |
| ETL DDL | [etl/](etl/) |

## Known operational state

| Item | Status |
|------|--------|
| Pipeline schedule | Manual trigger (daily 2AM target — pending IT enable) |
| Last full successful run | 2026-05-04 (Bob Standards rebuild verification) |
| Full runtime | ~31 minutes |
| Alerting | BLOCKED — Mail.Send / Teams permissions not granted |
| CI/CD | BLOCKED — Azure DevOps access not granted |
| Schedule trigger auto-deploy | BLOCKED — IT permission required |
