# ADR-002: EDW Supplement Exit Strategy For v10

Date: 2026-05-01

Status: Proposed — Active (4 EDW supplement tables still in `Staging_WRK`, pending Enterprise Lakehouse data completeness)

## Context

The v9 Supply Chain Forecast Accuracy implementation still uses four temporary `_edw` supplement paths because the shortcut-backed `Enterprise_Lakehouse` sources were not equally complete or stable for all required objects.

Verified local evidence:

- `01_Architect_v9_April/01_sc_forecast/README.md` documents four temporary `_edw` objects and marks two sources as `Ready`, two as `Not Ready`.
- `01_Architect_v9_April/01_sc_forecast/docs/operations/edw_source_swap.md` documents the EDW source swap and rollback path.
- `02_Architect_v10_May/detail_clone_v9_forecast/20260501_093155/sql/06_sp_registry.csv` confirms the live v9 registry still points four objects to `_edw`.
- `02_Architect_v10_May/detail_clone_v9_forecast/20260501_093155/pipeline_stored_procedures.csv` confirms `pl_sc_master` still starts with `bronze.usp_refresh_edw_tables`.

Platform context:

- [Verified] Fabric shortcuts can expose data without copying it, so they are the target Bronze access pattern when source contracts are stable.
- [Verified] Fabric medallion guidance recommends clear Bronze/Silver/Gold separation, with shortcuts preferred over copies for source data already available through OneLake-compatible paths.
- [Verified] The Lakehouse SQL analytics endpoint is read-only, so Warehouse-owned persisted staging remains valid when the framework needs controlled persisted state, reconciliation, replay, or fallback.

## Decision

Initial v10 keeps all four `_edw` fallback paths active.

The objects are split by exit maturity:

| Object | Initial v10 status | Reason |
|---|---|---|
| `brz_saleshistory_afi__invoicedetail` | `EDWSupplement_ExitCandidate` | v9 note marks Enterprise Lakehouse source `Ready`, but live v9 still uses `_edw` |
| `brz_saleshistory_afi__invoiceheader` | `EDWSupplement_NotReady` | v9 note marks Enterprise Lakehouse source `Not Ready` |
| `brz_supplychain_enh_1__demandforecastsnapshotdaily` | `EDWSupplement_NotReady` | v9 note marks source `Not Ready`; grain and coverage are more important than raw row count |
| `ref_product` | `EDWSupplement_ExitCandidate` plus owner decision | v9 note marks source `Ready`, but ownership may belong to EnterpriseData if reusable |

Rules:

- No bulk switch from `_edw` to direct shortcut.
- No object moves from `EDWSupplement` to `DirectShortcut` without dual-read validation.
- No object cuts over without Bob/Rakesh or assigned technical approver sign-off.
- `_edw` fallback remains as `RetainedFallback` after cutover until the rollback window closes.
- `bronze.usp_refresh_edw_tables` is removed only after all four objects reach `RetiredFallback` and explicit destructive-operation approval is granted.

## Consequences

Positive:

- Preserves v9 operational correctness while v10 moves toward cleaner medallion alignment.
- Avoids treating all four `_edw` objects as equally ready.
- Keeps a rollback path for high-risk source swaps.
- Gives Bob/Rakesh an object-level approval model instead of a vague architecture claim.

Costs and risks:

- v10 must carry fallback routing metadata during transition.
- Reconciliation tables and validation rules must exist before any exit candidate is cut over.
- The `refresh_edw` or v10 equivalent remains in the dependency chain until all four objects exit.
- Cleanup takes longer because fallback retirement is intentionally delayed.

## Rejected Alternatives

### Immediate Full Direct Cutover

Rejected.

Reason:

- Live v9 still routes all four objects through `_edw`.
- Two objects are explicitly `Not Ready` in v9 notes.
- A direct-only switch would remove rollback before source coverage, grain, and metric parity are proven.

### Keep `_edw` Forever

Rejected as target state.

Reason:

- It keeps unnecessary duplication after sources become stable.
- It conflicts with the target medallion direction that treats shortcut-backed Enterprise access as logical Bronze.

### Delete `_edw` Immediately After First Passing Run

Rejected.

Reason:

- One passing run is not enough evidence for source stability, late-arriving changes, or downstream KPI parity.
- Fallback must remain through an approved rollback window.

### Bulk Switch All Four Objects Together

Rejected.

Reason:

- The four objects have different readiness states and risk profiles.
- `DemandForecastSnapshotDaily` needs grain and coverage validation that total row-count checks cannot prove.

## Validation Gates

Each object must pass these gates before cutover:

| Gate | Required evidence |
|---|---|
| Schema parity | Column presence, type compatibility, nullability compatibility |
| Grain parity | Business grain and key duplicate pattern match expected downstream behavior |
| Date coverage | Min/max date and required history window match v9 needs |
| Row-count parity | Counts by day/month/business slice, not just total rows |
| Key coverage | Anti-join missing keys checked in both directions |
| Metric parity | Critical Silver/Gold metrics remain within approved threshold |
| DQ parity | Existing v9 DQ rules remain green or approved as warning |
| Performance | Direct shortcut read is stable enough for pipeline SLA |
| Lineage | Direct logical source and fallback source remain traceable |
| Approval | Bob/Rakesh or assigned approver signs off object-by-object |

## Implementation Linkage

Detailed implementation rules are maintained in:

- `02_Architect_v10_May/15_v10_edw_supplement_exit_strategy.md`
- `02_Architect_v10_May/12_v10_object_classification_mapping.md`
- `02_Architect_v10_May/14_v10_step_by_step_implementation_runbook.md`
- `02_Architect_v10_May/16_v10_readiness_scorecard_and_v9_cleanup.md`

## References

- Microsoft Fabric shortcuts: https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-shortcuts
- Microsoft Fabric medallion architecture: https://learn.microsoft.com/en-us/fabric/onelake/onelake-medallion-lakehouse-architecture
- Lakehouse SQL analytics endpoint: https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-sql-analytics-endpoint
