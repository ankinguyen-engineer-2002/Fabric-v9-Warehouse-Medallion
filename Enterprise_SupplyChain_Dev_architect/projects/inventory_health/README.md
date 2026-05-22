# inventory_health — Inventory Health Mart

> **Status (updated 2026-05-19):** CODE-AUTHORED · NOT YET DEPLOYED · **Gold schema:** `InventoryHealth_DW`
> Source: deliverable v1 (`_source_v1/`, archived gitignored). Standardized into v10 v_* views following "1 SP + N views" pattern. **Bronze layer 100% covered** (3 Enterprise loads done by Dhivya 2026-05-18 + 2 SC_LH workarounds via Aric dataflows). Deploy now blocked only on **3 Robert sign-offs** (H1/H5/M3).

## What

End-to-end Inventory Health analytics mart on Microsoft Fabric. Combines current + weekly inventory snapshots, supply plans, purchase/manufacturing orders, sales movement history, ATP, and allocated demand into a unified Gold serving layer for Power BI Direct Lake reporting via the `InventoryHealth` semantic model.

Phase 1 scope: 26 of 30 KPIs from BRD v1 (rest are Phase 2 — storage cube physical, warehouse-physical). 14 Track A fixes applied during 2-person QC review (2026-05-17); fixes preserved through view-conversion.

## Live infrastructure snapshot (planned, not yet deployed)

| Item | Value |
|------|-------|
| Workspace DEV | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| Processing WH | `c0262cef-b8a7-495f-bccc-53b098c7948c` (`SupplyChain_Processing_Warehouse`) |
| Gold WH | `98e2a911-5af9-442e-9cc8-5d8dadb8b762` (`SupplyChain_Gold_Warehouse`) |
| SQL Endpoint | `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com` |
| New Schemas | 1 in Processing (`InventoryHistory_Enh`) + 1 in Gold (`InventoryHealth_DW`) + 1 NEW row in existing `ReferenceMaster_Enh` (Vendor) |
| Views authored | **34** (1 RefMaster.v_Vendor + 25 Silver `v_*` + 8 Gold `v_*`) |
| Registry rows (planned) | **33** (1 ReferenceMaster + 24 DomainSilver + 8 Gold) |
| DQ rules (planned) | **27** (23 active + 4 inactive pending sources) |
| Semantic model | `InventoryHealth` TMDL (7 user-facing tables + 1 hidden helper + 30 DAX measures) |
| Naming convention | Bob-aligned per ADR-008: `_Enh` (Silver) / `_DW` (Gold), `v_*` view prefix |
| Control plane reuse | `Meta.AssetRegistry`, `Meta.DQRule`, `Meta.LineageEdge` (no project-specific procs) |
| Pipelines reused | 7 v10 pipelines (no new pipeline; multi-mart `pl_sc_master` ForEach auto-picks `project='inventory_health'`) |

## Live row counts

**Not yet measured** — deploy blocked. Expected magnitudes from deliverable v1 estimates:
- `FactInventoryHealthSnapshot`: O(10M rows) (item × warehouse × 7 daily + ~104 weekly snapshots)
- `FactInventoryRiskForward`: O(1M rows) (item × warehouse × 4 forward weeks)
- Silver helpers: O(50M) (Item × Warehouse × AsOfDate)
- Silver base: O(420M) (sum across 12 base tables, similar to forecast)

## Quick links

| Section | Doc |
|---------|-----|
| Workspace + IDs | [00_workspace.md](00_workspace.md) |
| Bronze layer (32 sources: 30 Enterprise ready + 2 SC_LH workaround) | [10_bronze.md](10_bronze.md) |
| Silver layer (1 RefMaster + 24 InventoryHistory_Enh) | [20_silver.md](20_silver.md) |
| Gold layer (8 InventoryHealth_DW) | [30_gold.md](30_gold.md) |
| Pipelines (reuses existing 7) | [40_pipelines.md](40_pipelines.md) |
| Semantic model + 30 DAX | [50_semantic.md](50_semantic.md) |
| Lineage | [60_lineage.md](60_lineage.md) |
| ETL views + registry | [etl/](etl/) |
| Semantic TMDL/DAX | [semantic/](semantic/) |
| Open questions (3 Robert + 2 DE US workaround pending + Bob Q) | [_open_questions_for_bob.md](_open_questions_for_bob.md) |
| Source deliverable v1 (gitignored) | [_source_v1/](_source_v1/) |
| Dataflow drafts (7 created; 2 still relevant + 2 deprecation cleanup) | [_dataflow_drafts/](_dataflow_drafts/) |

## Known operational state

| Item | Status |
|------|--------|
| ETL views authored | ✅ DONE (2026-05-18); Silver source switches applied 2026-05-19 |
| Registry rows authored | ✅ DONE; A2+A3 flipped `is_active=1` 2026-05-19 |
| DQ rules authored | ✅ DONE; pending `expected_zero` rule for 5 deprecated cols + `expected_dup_ratio_max` for Logility |
| Semantic model TMDL ported (`gold.` → `InventoryHealth_DW.`) | ✅ DONE |
| Deploy to Fabric | ⏳ NOT STARTED — bronze unblocked (Dhivya + workarounds); ETL source refs migrated to EL 2026-05-19; now blocked only on (a) Robert sign-off, (b) user go-ahead |
| Bronze sources (5 originally stale/missing) | ✅ 3 EL loads (PoDetail 21.95M + PoMaster 5.69M + Logility 38.36M, Dhivya 2026-05-18, verified pyodbc 2026-05-19) + 2 SC_LH workarounds (`df_brz_ItemBalance` 48.97M + `df_brz_PurchaseOrderSnapshot` ~2B) |
| Column-deprecation finding (5 cols) | ✅ Verified zero on EDW source: ITBEXT.CRHLD/DLHLD/TOHLD/ATPQT + ITEMBL.PHYOH → planned `expected_zero` DQ rule + delete 2 reload dataflows |
| Dup classification (Rakeshbalaji Slack 2026-05-09) | ✅ Verified 2026-05-19: PoDetail = TRUE row dup (1 pair, all 53 cols identical) → ROW_NUMBER drops safely; Logility = GRAIN CONFLICT (9,128 pairs, 6 metrics differ) → view ORDER BY rewritten to prefer non-zero metrics row |
| ETL Silver source-path migration (2026-05-19) | ✅ DONE: `v_PurchaseOrder` LEFT JOIN switched to EL.PoMaster; `v_LogilityItemStatus` switched to EL.DemandFulfillmentCommonContainer_Logility + new grain-conflict ORDER BY |
| 3 Robert sign-offs (H1/H5/M3) | ⏳ email pending (see `_open_questions_for_bob.md`) — **only remaining blocker** |
| Pipeline schedule | N/A until deploy |
| Alerting / CI / Schedule trigger | BLOCKED — same IT permission issue as forecast |

## Track A fixes preserved through v10 port (deliverable v1 → views)

| # | Code | Where in v10 | Robert sign-off |
|---|------|--------------|---|
| 1 | H1 ItemAllocationFlag=2 | [silver_views.sql:v_AllocatedDemandCandidate](etl/silver_views.sql) | ⏳ |
| 2 | H2 ATPSUM UNPIVOT APAT01-43 | [silver_views.sql:v_AtpWeekEnding](etl/silver_views.sql) | n/a (data shape) |
| 3 | H3 FG-only + WH exclusion | [silver_views.sql:v_InventoryCurrent](etl/silver_views.sql) | n/a (matches sếp) |
| 4 | H4 ORDER BY FiscalMonthYear | [gold_views.sql:v_CogsRollingHelper](etl/gold_views.sql) | n/a (math) |
| 5 | H5 WeekFourFlag exact week | [gold_views.sql:v_FactInventoryRiskForward](etl/gold_views.sql) | ⏳ |
| 6 | M1 Saturday DATENAME | N/A in v10 (cron handled by `Meta.ufn_should_run` + registry `cron_expression`) | n/a |
| 7 | M2 Walrus removed | N/A (no procedural SQL in v10 views) | n/a |
| 8 | M3 Cogs52W → Cogs52M | [gold_views.sql:v_CogsRollingHelper](etl/gold_views.sql) + TMDL + DAX | ⏳ |
| 9 | M4 SLOB NULL guard | [gold_views.sql:v_FactInventoryHealthSnapshot](etl/gold_views.sql) | n/a (defensive) |
| 10 | M5 AWD COUNTROWS SUMMARIZE | [semantic/Measures_DAX.dax](semantic/Measures_DAX.dax) verbatim | n/a (math) |
| 11 | B1 PoDetail Enterprise source | [silver_views.sql:v_PurchaseOrder](etl/silver_views.sql) | n/a (data switch) |
| 12 | B2 DemandForecast source | ~~v_ForecastCurrent~~ **DROPPED 2026-05-22 (orphan in Option B refactor; KPI #7 served via ForecastSnapshotWeekly history). B2 fix preserved in git history.** | n/a |
| 13 | B3 Warehouse exclusion flags | [silver_views.sql:v_WarehouseExt](etl/silver_views.sql) + v_InventoryCurrent + v_PurchaseOrder | n/a |
| 14 | M3 doc trail | inline comments in views + TMDL/DAX | n/a |

## Migration deltas vs deliverable v1

| Aspect | Deliverable v1 | v10 (this folder) |
|---|---|---|
| Silver schema | `silver` (lowercase, flat 35 tables) | `InventoryHistory_Enh` (**22 active tables post-2026-05-22 cleanup**: was 24, -2 dropped MovementHistory + ForecastCurrent, -1 deactivated LogilityItemStatusSnapshotWeekly) + `ReferenceMaster_Enh.Vendor` (NEW) |
| Gold schema | `gold` (lowercase, flat 8 tables) | `InventoryHealth_DW` (**6 active inv_health-only post-2026-05-22**: was 8, -1 dropped DimRuleVersion + -1 dropped DimDate) + 1 shared dim `ForecastAccuracy_DW.DimCalendar` (cross-mart) |
| Warehouse refs | `SupplyChain Processing Warehouse` (space) | `SupplyChain_Processing_Warehouse` (underscore) |
| Load orchestration | 14 custom `usp_Build_*` procs + 1 `usp_RefreshAll` | 1 generic `Meta.usp_GenericLoad` + 34 views + 33 registry rows |
| Control plane | None | Full `Meta.*` integration (registry + DQ + lineage + audit) |
| Pipeline | Manual exec | Registry-driven multi-mart via `pl_sc_master` |
| Watermark | `silver.EtlWatermark` table (5 rows) | `Meta.AssetRegistry.last_watermark_value` column |
| TMDL bind | `schemaName: gold` | `schemaName: InventoryHealth_DW` |
