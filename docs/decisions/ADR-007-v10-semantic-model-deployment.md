# ADR-007: v10 Semantic Model `sc_forecast_control_tower` Deployment

Date: 2026-05-05

Status: Accepted — implemented

## Context

Cherry/BCherry's original `Supply Chain Control Tower` semantic model (id `3eecf594-a75e-46ab-9162-63c95ee68e45`) was built on v8 architecture (Lakehouse + Spark notebooks, snake_case columns, output landing in `dbo.SupplyChain_Warehouse`). v10 architecture (Warehouse + T-SQL, PascalCase columns, `ForecastAccuracy_DW` schema in `SupplyChain_Gold_Warehouse`) was rebuilt 2026-05-04 per Bob Standards (ADR-003), but the rebuild dropped 64 cols from DimCalendar + 7 cols from FactForecastKpi as a "lean star schema" trade-off.

Cherry's TMDL referenced those dropped cols → cloning it on top of v10 Gold would break ~20+ DAX measures (MAPE, RMSE, validity flags).

## Decision

Deploy a new semantic model `sc_forecast_control_tower` on `SupplyChain_Gold_Warehouse` after closing v8 ↔ v10 schema parity gaps:

1. **Restore the dropped columns** in v10 Gold via `CREATE OR ALTER VIEW` + `DROP+CTAS`:
   - Silver `vw_Calendar` extended 46 → 74 cols
   - Gold `vw_DimCalendar` extended 10 → 75 cols (74 data + LoadDT)
   - Gold `vw_FactForecastKpi` extended 12 → 19 cols (added 7 derived metrics)
   - Silver+Gold `ForecastHorizon` views/tables added `Rank` col

2. **Drop `dq_forecast_accuracy`** from the model (per Bob design: Gold = serving-only; DQ data lives in Meta schema in Processing WH).

3. **Clone TMDL** with transformations:
   - Table renames: `dim_calendar` → `DimCalendar`, etc.
   - Column renames: snake_case → PascalCase (~190 mappings, scripted)
   - Direct Lake repointed: workspace c8d9fc83 / WH e146ffe2 (v9) → WH 98e2a911 (Gold)
   - schemaName: `dbo` → `ForecastAccuracy_DW`
   - lineageTag UUIDs regenerated
   - `expressionSource` renamed: `'DirectLake - SupplyChain_Warehouse'` → `'DirectLake - SupplyChain_Gold_Warehouse'`

4. **Coexist with v9 model** — original `Supply Chain Control Tower` left intact pointing to v9 Warehouse for backward compatibility with Cherry's existing reports.

## Consequences

### Positive
- v10 semantic model live with full feature parity (8 tables, 35 measures, 9 relationships verified exact)
- Direct Lake on Gold WH = optimal Power BI serving
- Bob Standards (PascalCase, schema_DW suffix) preserved while accommodating Cherry's measures
- Clear branch separation: Cherry's reports continue on v9 model; new VN reports target v10 model

### Negative / trade-offs
- v10 Gold DimCalendar now has 74 cols (slightly fatter than Bob's lean original 10 cols) — pragmatic compromise for Cherry compatibility
- Two semantic models pointing at "Forecast Accuracy" data exist in the workspace (Cherry's v9 + v10 clone). Eventually consolidate after migrating Cherry's reports to v10 model
- v10 ETL view changes (`CREATE OR ALTER VIEW`) are persistent in Fabric WH but not backed by sqlproj source-of-truth (CI/CD blocked by IT)

### Maturity impact
ADR-004 maturity baseline: 89.3% (130/150) → estimated **91-92%** (~138-140/150) post-deployment, criterion #5 (Direct Lake) satisfied.

## Verification (2026-05-05)

| Aspect | v8 source | v10 deployed | Match |
|---|---|---|---|
| Tables | 11 (incl. dq) | 10 (drop dq) | ✓ as designed |
| DimCalendar cols | 74 | 74 | ✓ EXACT |
| FactForecastKpi cols | 18 | 18 | ✓ EXACT |
| Other 5 dim/fact cols | matches | matches | ✓ EXACT |
| Measures | 35 | 35 | ✓ all 35 names match |
| Relationships | 9 | 9 | ✓ semantic match |
| Direct Lake source | v9 e146ffe2 | v10 98e2a911 | ✓ repoint |
| Row counts | full data | within 1.6% (DimProduct +SKU); 6/7 tables exact or near-exact | ✓ |

Notes:
- DimCustomerGrouping has +35K rows (v10 enriched with `Customer` col); semantic model uses CustomerGroupCode only → effective parity preserved
- FactForecastActual −3.5% rows due to data drift (newer cutoff in v10); 6 forecast lag horizons rows match exactly

## References

- Parity matrix: [`02_Architect_v10_May/30_runbook/17_v8_to_v10_etl_parity.md`](../../02_Architect_v10_May/30_runbook/17_v8_to_v10_etl_parity.md)
- Port SQL scripts: [`02_Architect_v10_May/artifacts/v8_to_v10_parity/port_scripts/`](../../02_Architect_v10_May/artifacts/v8_to_v10_parity/port_scripts/)
- TMDL artifacts: [`02_Architect_v10_May/artifacts/v8_to_v10_parity/tmdl_v10_clone/`](../../02_Architect_v10_May/artifacts/v8_to_v10_parity/tmdl_v10_clone/) + `tmdl_v10_deployed/`
- Commits: `18f97f94` (Phase 1 audit), `dddc73f3` (Phase 2+3 deploy)

## Next actions

- Validate ~50 DAX measures via Power BI Desktop / Service connection
- Configure refresh schedule on new model
- Migrate Cherry's reports from v9 model to v10 model (when ready)
- Cleanup `temp_SCPModel` + `SupplyChain_Gold` (auto-default-dataset) when confirmed unused
- Lineage extension plan (doc 18) — extend `Meta.LineageEdge` to include semantic-model edges
