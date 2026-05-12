# forecast — Forecast Accuracy Mart

> **Status:** LIVE · **Gold schema:** `ForecastAccuracy_DW` · **Last verified:** 2026-05-12 (live Fabric re-query)

## What

End-to-end Forecast Accuracy analytics mart on Microsoft Fabric. Combines actual sales demand, forecast demand, and naive forecast into a unified Gold serving layer for Power BI Direct Lake reporting via the `sc_forecast_control_tower` semantic model.

## Live infrastructure snapshot

| Item | Value |
|------|-------|
| Workspace DEV | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| Processing WH | `c0262cef-b8a7-495f-bccc-53b098c7948c` |
| Gold WH | `98e2a911-5af9-442e-9cc8-5d8dadb8b762` |
| SQL Endpoint | `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com` |
| Schemas | 6 in Processing (Staging_Wrk, ReferenceMaster_Enh, SalesHistory_Enh, ForecastHistory_Enh, OpenOrderHistory_Enh, Meta) + 1 in Gold (ForecastAccuracy_DW) |
| Total tables | **52** (45 Processing: 22 data + 23 Meta; 7 Gold: 2 Fact + 5 Dim) |
| Total views | **34** (27 Processing: 23 data + 4 Meta; 7 Gold) |
| Total SPs / functions | **21** (18 SPs: 17 Meta + 1 Staging_Wrk; 3 Meta functions) |
| Registry assets (active) | **33** (4 LogicalBronze + 4 Staging + 10 ReferenceMaster + 8 DomainSilver + 7 Gold) |
| Lineage edges | **60** (53 direct + 7 semantic) |
| DQ rules | **30 active** (17 completeness + 13 row_count) / 54 total (12 freshness + 12 uniqueness deactivated) |
| Source contracts | 674 across 52 source feeds |
| Reconciliation rules | 6 (scaffolded) |
| DAG waves | 3 (Wave 0 / Wave 1 / Wave 2 — 8 entries in SilverDagWaveRuntime) |
| Pipelines | 7 v10 pipelines (pl_sc_master, pl_sc_mart, pl_sc_staging, pl_sc_silver, pl_sc_silver_wave, pl_sc_gold, pl_dq_check) |
| Semantic model | `sc_forecast_control_tower` (`f06a2361-15fd-4f91-9d37-941fefe62aaf`) |
| Naming convention | Bob-aligned per ADR-008: `_Enh`/`_Wrk` (PascalCase casing), `v_*` view prefix, `_DW` ALL CAPS for Gold |
| Control plane (Bob-pattern) | `Meta.TableDictionary` (table, 33 rows, 69 cols ≈ 60% cell fill) + `Meta.TableDictionary_UpdateLog` (event log) + `Meta.AuditLog` (10-col superset of Bob's 4-col) |

## Live row counts (2026-05-12)

### Processing WH (Silver) — 339,034,150 rows

| Schema | Rows | Tables |
|--------|-----:|-------:|
| `Staging_Wrk` | 156,641,390 | 4 |
| `ReferenceMaster_Enh` | 637,360 | 10 |
| `SalesHistory_Enh` | 137,045,519 | 4 |
| `ForecastHistory_Enh` | 44,460,412 | 2 |
| `OpenOrderHistory_Enh` | 249,469 | 2 |

### Gold WH (`ForecastAccuracy_DW`) — 83,973,234 rows

| Type | Rows | Tables |
|------|-----:|-------:|
| Fact (FactForecastActual 47.1M + FactForecastKpi 36.4M) | 83,536,698 | 2 |
| Dim (DimCalendar 21.5K · DimCustomerGrouping 35.6K · DimProduct 379K · DimWarehouse 55 · DimForecastHorizon 8) | 436,536 | 5 |

**Grand total: 423,007,384 rows** across both warehouses.

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

## Known operational state (live 2026-05-12)

| Item | Status |
|------|--------|
| Pipeline schedule | Manual trigger (daily 2AM target — pending IT enable) |
| Last full successful run | `pl_sc_master` 2026-05-04 12:50 UTC, **2181s (~36m)** |
| Most recent run | 2026-05-10 09:19 UTC, **1801s (~30m), status = `partial`** (some assets failed — investigation needed) |
| Pre-Bob-rebuild full pass | 2026-05-02 03:54→04:25 UTC, ~31m (memory baseline) |
| Alerting | BLOCKED — Mail.Send / Teams permissions not granted (Q4 with Bob) |
| CI/CD | BLOCKED — Azure DevOps access not granted (Q4) |
| Schedule trigger auto-deploy | BLOCKED — IT permission required |
| DQ rule deactivation | 24 rules (12 freshness + 12 uniqueness) currently inactive; needs review |

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
