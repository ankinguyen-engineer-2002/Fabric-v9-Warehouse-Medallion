# 18 — Plan: Extend Lineage to Track Gold → Semantic Model Edges

**Date**: 2026-05-05
**Status**: PLAN (draft — needs Aric approval before Phase 2)
**Owner**: Aric (DataHub VN)

## 1. Problem Statement

Current `Meta.LineageEdge` (53 edges, last build 2026-05-04 13:47) tracks **only intra-warehouse edges**:
- Bronze (Lakehouse / Staging) → Silver (`*_ENH` schemas in Processing WH) → Gold (`ForecastAccuracy_DW` schema in Gold WH)

When standing in front of the lineage graph at the Gold layer, we cannot answer: **"Which semantic model is consuming each Gold table?"** This becomes important now that v10 has multiple semantic models on the same Gold WH:

| Gold table | Consumed by |
|---|---|
| `ForecastAccuracy_DW.DimCalendar` | ? |
| `ForecastAccuracy_DW.DimCustomerGrouping` | ? |
| `ForecastAccuracy_DW.DimWarehouse` | ? |
| `ForecastAccuracy_DW.DimProduct` | ? |
| `ForecastAccuracy_DW.DimForecastHorizon` | ? |
| `ForecastAccuracy_DW.FactForecastActual` | ? |
| `ForecastAccuracy_DW.FactForecastKpi` | ? |

Confirmed answer (manually traced 2026-05-05): all 7 → `sc_forecast_control_tower` (id `f06a2361-...`). Plus the auto-default-dataset `SupplyChain_Gold` references all tables in Gold WH by default.

## 2. Current State

### 2.1 Lineage system live status
- ✅ `Meta.LineageEdge` (53 edges) — auto-rebuilt by `Meta.usp_BuildLineage` from `AssetRegistry.source_objects`
- ✅ `Meta.usp_FinalizePipeline` calls `usp_BuildLineage` after every pipeline run → auto-update
- ✅ `pl_sc_master` runs hourly (last success `2026-05-04 01:00`) — but auto-trigger paused since Bob rebuild
- ✅ Streamlit lineage app [`https://vn-engineer-lineage.streamlit.app`](https://vn-engineer-lineage.streamlit.app) — HTTP 303 (live); code at `01_Architect_v9_April/lineage_explorer/`

### 2.2 Existing Meta scaffold for semantic model tracking
`Meta.SemanticModelContract` (table EXISTS but underused):

| Column | Type |
|---|---|
| contract_id | varchar |
| gold_asset_id | varchar |
| semantic_model_name | varchar |
| source_mode | varchar (e.g., 'DirectLake') |
| direct_lake_required | bit |
| fallback_allowed | bit |
| validation_status | varchar |
| last_validated_utc | datetime2 |
| notes | varchar |

Current rows: 2 (only `FactForecastActual` + `FactForecastKpi` → `SupplyChain_Gold` auto-dataset, both `validation_status='Pending'`, `last_validated_utc=NULL`).

### 2.3 Why T-SQL alone can't refresh semantic model lineage
`usp_BuildLineage` is pure T-SQL inside Fabric Warehouse — cannot call Fabric REST API to discover semantic models. Need an external compute step (Python script with `az` token, or notebook activity, or Fabric pipeline Web activity).

## 3. Proposed Architecture

### 3.1 Schema design — extend Meta tables

#### A. `Meta.SemanticModelContract` (existing — repurpose for live tracking)

Extend existing table; one row **per (gold_asset, semantic_model)** pair. Schema unchanged. Currently 2 rows; expected to grow to **N × M** rows (N = Gold tables, M = consuming semantic models). For our workspace today: 7 × 1 = 7 rows minimum (sc_forecast_control_tower) + auto-default-dataset rows.

#### B. `Meta.LineageEdge` (existing — add semantic edges)

Add rows with `edge_type='semantic'`:

| edge_id | source_asset | target_asset | edge_type | transform_type |
|---|---|---|---|---|
| `semantic::sc_forecast_control_tower::DimCalendar` | `ForecastAccuracy_DW.DimCalendar` | `SemanticModel.sc_forecast_control_tower` | `semantic` | `directLake` |
| ... (× 7 for sc_forecast_control_tower) ... | | | | |

Streamlit lineage app already filters by `edge_type` — adding `semantic` type renders without code change (just labels need updating).

### 3.2 Population workflow — Python script

New tool: `02_Architect_v10_May/tools/build_semantic_model_lineage.py`

Logic (pseudocode):
```python
ws_id = c8d9fc83-18b6-4e1d-8264-0b49eed36fe0
gold_wh_id = 98e2a911-5af9-442e-9cc8-5d8dadb8b762

semantic_models = fabric_api.list_semantic_models(ws_id)
edges, contracts = [], []

for sm in semantic_models:
    tmdl = fabric_api.get_semantic_model_definition(sm.id, format='TMDL')
    parts = parse_tmdl(tmdl)
    
    # Filter: which Direct Lake source does this model use?
    expressions = parts.expressions['DirectLake - *']
    if gold_wh_id in expression.source_url:
        # This model reads from Gold WH
        for table_partition in parts.tables:
            entity = partition.entityName
            schema = partition.schemaName
            gold_asset_id = f"{schema}.{entity}"
            
            edges.append({
                'edge_id': f'semantic::{sm.name}::{entity}',
                'source_asset': gold_asset_id,
                'target_asset': f'SemanticModel.{sm.name}',
                'edge_type': 'semantic',
                'transform_type': partition.mode,  # 'directLake' / 'directQuery' / 'import'
            })
            contracts.append({
                'contract_id': f'semantic::{sm.name}::{entity}',
                'gold_asset_id': gold_asset_id,
                'semantic_model_name': sm.name,
                'source_mode': partition.mode,
                'direct_lake_required': partition.mode == 'directLake',
                'fallback_allowed': False,
                'validation_status': 'discovered',
                'last_validated_utc': now_utc(),
            })

# Write to Meta tables via pyodbc
truncate_then_insert(Meta.SemanticModelContract, contracts)
delete_where(Meta.LineageEdge, edge_type='semantic')
insert(Meta.LineageEdge, edges)
```

Estimated SQL writes: ~10-30 rows per run (small).

### 3.3 Schedule & integration

Two options:

#### Option A — Standalone cron (LOW effort, standalone)
- Run script daily 03:00 UTC+7 (1h after `pl_sc_master` 02:00)
- Use `cron` on local machine OR GitHub Action (workflow_dispatch + schedule)
- Pros: simple, no Fabric pipeline change
- Cons: not integrated with existing pipeline, separate auth

#### Option B — Hook into `pl_sc_master` (MEDIUM effort, integrated)
- Add Web Activity to `pl_sc_master` after `usp_FinalizePipeline`
- Web Activity calls Azure Function or Fabric Function that runs the Python script
- Activity stores result in `Meta.SemanticModelContract`
- Pros: lineage stays in sync per pipeline run
- Cons: requires Fabric Function or Azure Function setup (cost + complexity)

**Recommendation**: Start with **Option A** (cron via GitHub Action), upgrade to Option B later when alerting/CI infrastructure unblocks (per ADR-005).

### 3.4 Streamlit visualization update

`01_Architect_v9_April/lineage_explorer/app.py` — confirm existing filter logic supports `edge_type='semantic'`. Likely needs:
- Color/icon override for `SemanticModel.*` nodes (e.g., gold star icon)
- New filter chip: "Show semantic models" toggle
- Tooltip: show `source_mode` on hover

Effort: 1 PR to lineage_explorer/.

## 4. Implementation Plan

### Phase 1 — POC + populate (~1h)

1. Build `tools/build_semantic_model_lineage.py` with hard-coded workspace ID
2. Run once locally → populate 7-10 rows in `Meta.SemanticModelContract` + corresponding edges in `Meta.LineageEdge`
3. Verify edges visible in Streamlit lineage app
4. Confirm `usp_BuildLineage` does NOT clobber semantic edges (filter by edge_type)

### Phase 2 — Auto-update setup (~1h)

5. Add GitHub Action `.github/workflows/refresh-semantic-lineage.yml`:
   - Triggers: `workflow_dispatch` + `schedule: '0 19 * * *'` (daily 02:00 UTC+7 = 19:00 UTC prev day)
   - Steps: setup-python, az login (OIDC service principal), run script
   - Concerns: need Azure SP credentials in GH secrets
6. Document trigger model in this doc

### Phase 3 — Streamlit update (~30 min)

7. PR to `01_Architect_v9_April/lineage_explorer/app.py`: add semantic-model node rendering
8. Deploy lineage app refresh

### Phase 4 — Guard `usp_BuildLineage` (~15 min)

9. Modify `usp_BuildLineage` so it only deletes `edge_type IN ('direct','derived')`, preserving semantic edges
   ```sql
   DELETE FROM Meta.LineageEdge WHERE edge_type IN ('direct','derived');
   ```
10. Apply via `CREATE OR ALTER PROCEDURE` on Processing WH

## 5. Acceptance Criteria

- [ ] `Meta.SemanticModelContract` has at least 7 rows for `sc_forecast_control_tower` (one per Gold table)
- [ ] `Meta.LineageEdge` has corresponding `edge_type='semantic'` rows (same count)
- [ ] Streamlit lineage app visually distinguishes semantic-model nodes from warehouse nodes
- [ ] After `pl_sc_master` runs, semantic edges remain (not clobbered by `usp_BuildLineage`)
- [ ] After scheduled refresh runs, `last_validated_utc` updates daily

## 6. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Fabric API rate-limit when scanning many models | Limit to workspaces explicitly; skip auto-default datasets |
| GitHub Action SP credentials leak | Use OIDC + workspace-scoped role |
| `usp_BuildLineage` accidentally wipes semantic edges | Phase 4 guard (filter by edge_type) |
| TMDL parser breaks on new Power BI features | Keep parser strict, log + skip unparsable models |

## 7. Open Decisions

- [ ] **Naming convention** for `target_asset` in `Meta.LineageEdge` for semantic model nodes: `SemanticModel.<name>` vs `Fabric.SemanticModel/<id>` vs `<workspaceId>/SemanticModel/<id>`. Prefer `SemanticModel.<name>` for readability.
- [ ] **Should we track all semantic models** in workspace or only those reading from Gold WH? Phase 1 = only Gold readers; can expand later.
- [ ] **Cleanup `SupplyChain_Gold` auto-default-dataset**: confirm whether to drop or keep. If kept, will appear as a separate node in lineage.

## 8. Status

- [x] Plan drafted (this doc)
- [x] **Phase 1 POC — DONE 2026-05-05**: `tools/build_semantic_model_lineage.py` discovers all 4 semantic models, identifies 1 Gold consumer (`sc_forecast_control_tower`), populates 7 edges in `Meta.LineageEdge` + 7 contracts in `Meta.SemanticModelContract`
- [x] **Phase 4 guard — DONE 2026-05-05**: `Meta.usp_BuildLineage` now filters `DELETE WHERE edge_type IN ('direct','derived')`, preserving semantic edges. Tested rebuild — semantic edges survived.
- [x] **Phase 2 cron schedule — DONE 2026-05-05**: GitHub Action `.github/workflows/refresh_lineage_data.yml` extended with new step "Refresh Semantic Model Lineage" that discovers Gold consumers via Fabric API + writes to Meta tables BEFORE the existing CSV export step. Runs every 10 min via existing cron `*/10 * * * *`. Reuses existing SP credentials in GH secrets.
- [x] **Phase 3 Streamlit visual — DONE 2026-05-05**: Updated `01_Architect_v9_April/lineage_explorer/app.py` `get_tier()` to recognize `SemanticModel.*` nodes (returns `sem` tier); updated `templates/lineage.html` adding `sem` tier (color `#ec4899` pink, icon ✦) + LAYER_LABELS/COLORS layer 9 + FIXED_LAYERS sem→9. Source/target node ID logic preserves `SemanticModel.<name>` full path for clarity.

### Live state after Phase 1+4 (2026-05-05)
- `Meta.LineageEdge`: 53 direct + 7 semantic = 60 edges
- `Meta.SemanticModelContract`: 7 rows (was 2 stale + 0 live)
- 7 semantic edges visible in lineage:
  ```
  ForecastAccuracy_DW.DimCalendar              → SemanticModel.sc_forecast_control_tower (directLake)
  ForecastAccuracy_DW.DimCustomerGrouping      → SemanticModel.sc_forecast_control_tower (directLake)
  ForecastAccuracy_DW.DimForecastHorizon       → SemanticModel.sc_forecast_control_tower (directLake)
  ForecastAccuracy_DW.DimProduct               → SemanticModel.sc_forecast_control_tower (directLake)
  ForecastAccuracy_DW.DimWarehouse             → SemanticModel.sc_forecast_control_tower (directLake)
  ForecastAccuracy_DW.FactForecastActual       → SemanticModel.sc_forecast_control_tower (directLake)
  ForecastAccuracy_DW.FactForecastKpi          → SemanticModel.sc_forecast_control_tower (directLake)
  ```

### Manual refresh procedure (until Phase 2 cron is set up)
```bash
cd /Users/MAC/Documents/20260413_Fabric_Refactor_Architect
python3 02_Architect_v10_May/tools/build_semantic_model_lineage.py
```
Run anytime a semantic model is added/repointed/removed. Daily `pl_sc_master` will preserve the semantic edges automatically (Phase 4 guard).

## References

- Lineage tables: `Meta.LineageEdge`, `Meta.SemanticModelContract`, `Meta.SourceContract`, `Meta.AssetRegistry`
- SP: `Meta.usp_BuildLineage`, `Meta.usp_FinalizePipeline`
- Semantic model deployed: `sc_forecast_control_tower` (id `f06a2361-15fd-4f91-9d37-941fefe62aaf`) — see ADR-007
- Streamlit app: `01_Architect_v9_April/lineage_explorer/app.py` ([live](https://vn-engineer-lineage.streamlit.app))
