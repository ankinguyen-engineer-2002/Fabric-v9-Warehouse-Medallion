# forecast — Forecast Accuracy Mart

> **Status:** LIVE · **Gold schema:** `ForecastAccuracy_DW` · **Last scan:** 2026-05-10 (post Bob alignment, ADR-008)

## What

End-to-end Forecast Accuracy analytics mart on Microsoft Fabric. Combines actual sales demand, forecast demand, and naive forecast into a unified Gold serving layer for Power BI Direct Lake reporting via the `sc_forecast_control_tower` semantic model.

## Live infrastructure snapshot

| Item | Value |
|------|-------|
| Workspace DEV | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| Processing WH | `c0262cef-b8a7-495f-bccc-53b098c7948c` |
| Gold WH | `98e2a911-5af9-442e-9cc8-5d8dadb8b762` |
| SQL Endpoint | `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com` |
| Schemas | 6 (Staging_Wrk, ReferenceMaster_Enh, SalesHistory_Enh, ForecastHistory_Enh, OpenOrderHistory_Enh, Meta) |
| Total tables | 52 (45 Processing + 7 Gold) |
| Total views | 30 (23 Processing + 7 Gold + 4 Meta utility views — formerly 35; vw_TableDictionary became real `Meta.TableDictionary` table) |
| Total SPs / functions | 21 (17 SPs + 3 functions in Meta + 1 SP in Staging_Wrk) |
| Registry assets | 33 |
| Lineage edges | 60 |
| DQ rules | 54 |
| DAG waves | 3 (Wave 0 / Wave 1 / Wave 2) |
| Pipelines | 7 |
| Semantic model | `sc_forecast_control_tower` (`f06a2361-15fd-4f91-9d37-941fefe62aaf`) |
| Naming convention | Bob-aligned per ADR-008: `_Enh`/`_Wrk` (lowercase casing), `v_*` view prefix, `_DW` ALL CAPS for Gold |
| Control plane (Bob-pattern) | `Meta.TableDictionary` (table, 33 rows, ~60% cell fill) + `Meta.TableDictionary_UpdateLog` (event log) + `Meta.AuditLog` (audit trail) |

## Live row counts

### Processing WH (Silver)

| Schema | Total rows |
|--------|-----------:|
| `Staging_Wrk` | 156,120,911 |
| `ReferenceMaster_Enh` | 637,360 |
| `SalesHistory_Enh` | 136,442,343 |
| `ForecastHistory_Enh` | 44,454,578 |
| `OpenOrderHistory_Enh` | 269,015 |

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
| Last full successful run | 2026-05-04 (Bob Standards rebuild verification); 2026-05-10 Bob alignment refactor (schema casing + view prefix + TableDictionary table) |
| Full runtime | ~31 minutes |
| Alerting | BLOCKED — Mail.Send / Teams permissions not granted |
| CI/CD | BLOCKED — Azure DevOps access not granted |
| Schedule trigger auto-deploy | BLOCKED — IT permission required |

## Bob alignment (2026-05-10) — what changed

Per Bob's reply email 2026-05-09 + scan of `EnterpriseData-Dev` workspace (see `_external_refs/enterprisedata-dev-docs/`), the following changes were made unilaterally (no Bob block needed) — see [ADR-008](../../../docs/decisions/ADR-008-bob-alignment-naming-and-integration.md):

### Naming alignment
- Schema casing `_ENH` → `_Enh`, `_WRK` → `_Wrk` (5 schemas renamed via `ALTER SCHEMA TRANSFER`, data preserved)
- View prefix `vw_*` → `v_*` (35 views recreated)
- `_DW` Gold suffix kept ALL CAPS (matches Bob's `MasterData_DW`/`SupplyChain_DW` precedent)

### Control plane port (Mức B per ADR-008)
- `Meta.vw_TableDictionary` (view) → `Meta.TableDictionary` (real table, 69 cols = 63 Bob-compatible + 6 VN extensions, 60.3% cell fill)
- New `Meta.TableDictionary_UpdateLog` table (mirror Bob's append-only event log)
- New `Meta.AuditLog` table (10 cols — superset of Bob's 4-col schema)
- 3 new SPs ported from Bob's pattern:
  - `Meta.usp_UpdateTableDictionary_ModifiedDate` — per-load INSERT/UPDATE
  - `Meta.usp_UpdateTableDictionaryModified` — batch sync `Modified` from UpdateLog
  - `Meta.usp_RefreshTableStats` — probe `INFORMATION_SCHEMA` for ColumnCount/Fabric defaults
- `Meta.usp_LogRun` v2 — auto-calls `usp_UpdateTableDictionary_ModifiedDate` on every load → TableDictionary stays in sync without manual triggers

### Pipelines patched
- 2 of 7 pipelines had hardcoded refs to old schema/view names (`pl_sc_staging`, `pl_sc_silver_wave`) — patched via Fabric REST API.

### Pending Bob (4 questions in `_open_questions_for_bob.md`)
- Cross-DB write to `EnterpriseData-Dev.ETL_Framework.DW_Developer.TableDictionary` (Q1)
- `MasterData_DW.DimDate/DimItemMaster` MERGE plan (Q2)
- `SupplyChain_Warehouse` in EnterpriseData hub creation (Q3)
- IT unblock: Mail.Send + Azure DevOps + read access (Q4)

### Artifacts
- `Enterprise_SupplyChain_Dev_architect/artifacts/bob_alignment_2026-05-10/` — execution scripts, generator, run logs, backup snapshot
