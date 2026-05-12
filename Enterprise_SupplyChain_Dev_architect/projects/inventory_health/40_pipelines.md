# 40 — Pipelines

> **Status:** Skeleton — no new pipelines needed. Existing 7 v10 pipelines pick up `inventory_health` mart via multi-mart ForEach.

## Pipeline reuse strategy

Per ADR-001 multi-mart design, **adding a new mart requires zero new pipelines**. The orchestrator `pl_sc_master` runs:

```
Lookup: SELECT DISTINCT project FROM Meta.AssetRegistry WHERE is_active=1
  ForEach project (concurrency=1)
    → Invoke pl_sc_mart(@project)
      → pl_sc_staging (if EDW supplement assets exist for project)
      → pl_sc_silver  → pl_sc_silver_wave (DAG waves)
      → pl_sc_gold    (cross-DB CTAS)
      → finalize
```

When `project='inventory_health'` rows are added to `Meta.AssetRegistry`, the existing pipeline picks them up automatically next run.

## Existing 7 v10 pipelines (no change needed)

| Pipeline | ID | Role |
|----------|----|------|
| `pl_sc_master` | `f36f56b8-5668-4a0c-b991-2c28302f1710` | Multi-mart orchestrator |
| `pl_sc_mart` | `20db5725-80e3-4081-9ef5-01700acdf3b3` | Per-mart wrapper |
| `pl_sc_staging` | `10221fb2-6e30-4911-9d95-d8dd67440d84` | EDW supplement load (if applicable) |
| `pl_sc_silver` | `7dc6ecda-56cc-4797-893c-1c502863323f` | Silver DAG dispatcher |
| `pl_sc_silver_wave` | `797b1a02-f973-4584-bd27-bb0151549d4b` | Wave executor (batch=8 parallel) |
| `pl_sc_gold` | `50ff6263-659d-4b09-9e45-b42a3434e093` | Gold cross-DB CTAS |
| `pl_dq_check` | `3c7c61f6-c184-41e5-8309-f9ac3260d38d` | DQ gate (standalone) |

## Registry rows needed for inventory_health (TBD)

Estimate ~10-15 rows in `Meta.AssetRegistry`:
- 2-4 Staging_Wrk (if EDW supplement needed)
- 5-7 Silver (3 schemas × ~2 tables each)
- 3-5 Gold (3 facts + 1-2 new dims)

Add via INSERT to `Meta.AssetRegistry` with `project='inventory_health'`. Then:
1. `EXEC Meta.usp_ComputeSilverWaves` (regenerate DAG)
2. `EXEC Meta.usp_BuildLineage` (rebuild edges)
3. Trigger `pl_sc_master` — multi-mart ForEach picks both `supplychain` (existing forecast) + `inventory_health`

## DQ rules needed

Add rows to `Meta.DQRule` per Silver/Gold table. Same 7 check types available (completeness, row_count, uniqueness, freshness, etc.).

## TBD

- [ ] Final asset list with `load_type` per asset
- [ ] Watermark columns for any `incremental` assets
- [ ] DAG `depends_on` graph (esp. `StockoutEvents` cross-mart dependency)
- [ ] Schedule: same daily 2AM UTC+7 trigger, or different cadence?
