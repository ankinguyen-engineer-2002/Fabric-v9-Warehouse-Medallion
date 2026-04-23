# Supply Chain Forecast — Project Overview
> SupplyChain Warehouse v9 | Microsoft Fabric | Pure T-SQL | Metadata-Driven
> Status: **Production** (daily 2AM UTC+7) | Score: 8.2/10 | Enterprise mapping: ~91%

---

## What This Is

A warehouse-native medallion architecture on Microsoft Fabric for supply chain demand forecasting at Ashley Furniture. Loads data from Enterprise_Lakehouse (and temporarily from EDW via `_edw` supplement tables), transforms through bronze/silver/gold layers, and serves a Power BI semantic model (SC_Control_Tower).

- **28 data tables** across 3 layers (bronze/silver/gold)
- **1 generic SP** handles all 28 tables (8 load patterns)
- **7 pipelines** with DAG-based silver orchestration
- **~91 total objects** including 11 meta tables, 30 views, 11 SPs, 3 functions

## Current Source State (2026-04-23)

4 bronze tables temporarily read from `_edw` supplement tables (EDW via Lakehouse `_ver2`) instead of Enterprise_Lakehouse. This is because EL has incomplete data for these tables. See [edw_source_swap.md](docs/operations/edw_source_swap.md) for rollback instructions.

---

## Documentation

### Architecture & Setup
| Doc | Description |
|-----|-------------|
| [architecture.md](docs/architecture.md) | All objects: names, row counts, pipeline IDs, source mappings |
| [setup.md](docs/setup.md) | Implementation log: Spark-to-T-SQL conversions, bugs, fixes |
| [pipeline.md](docs/pipeline.md) | Execution trace: actual SP names, durations, wave assignments |
| [v8_vs_v9_comparison.md](docs/v8_vs_v9_comparison.md) | V8 (notebook) vs V9 (warehouse) migration comparison |

### Operations
| Doc | Description |
|-----|-------------|
| [runbook.md](docs/operations/runbook.md) | Pipeline troubleshooting, common errors, re-run guide |
| [onboarding.md](docs/operations/onboarding.md) | Add new tables (2 SQL statements, no pipeline changes) |
| [scheduling.md](docs/operations/scheduling.md) | Cron, smart skip, concurrency, snapshot conflicts |
| [alerting.md](docs/operations/alerting.md) | Alerting design (blocked by IT permissions) |
| [edw_source_swap.md](docs/operations/edw_source_swap.md) | EDW source supplement: swap/rollback guide |
| [generic_sp_migration.md](docs/operations/generic_sp_migration.md) | Migration: 28 per-table SPs to 1 generic SP |
| [sqlproj_validation.md](docs/operations/sqlproj_validation.md) | .sqlproj build validation approaches |
| [timezone_sync.md](docs/operations/timezone_sync.md) | UTC + CST + VN timezone sync |

### Enterprise & Scale
| Doc | Description |
|-----|-------------|
| [roadmap.md](enterprise/roadmap.md) | 4-phase enterprise roadmap |
| [multi_mart_scale.md](enterprise/multi_mart_scale.md) | N marts parallel, cross-mart dependencies |
| [fabric_vs_enterprise.md](enterprise/fabric_vs_enterprise.md) | Enterprise ETL framework comparison |

---

## Quick Start

### Add a new bronze table (2 steps)
```sql
-- 1. Create view (ETL logic)
CREATE OR ALTER VIEW bronze.vw_brz_{name} AS
SELECT * FROM Enterprise_Lakehouse.{schema}.{table};

-- 2. Register in sp_registry
INSERT INTO meta.sp_registry (sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, is_active, source_objects, project, cron_expression)
VALUES ('meta.usp_generic_load', 'bronze.vw_brz_{name}',
    'bronze', 'brz_{name}', 'BRZ', 'overwrite', 'daily', 1,
    '["Enterprise_Lakehouse.{schema}.{table}"]', 'supplychain', '0 2 * * *');
-- Pipeline auto picks up next run. No pipeline changes needed.
```

### Run pipeline manually
Trigger `pl_sc_master` from Fabric Portal. Flow: refresh_edw -> log_start -> ForEach projects -> pl_sc_mart (bronze -> silver -> gold) -> finalize -> refresh SM.

### Troubleshoot a failure
See [runbook.md](docs/operations/runbook.md) for common errors and re-run procedures.

---

*Part of the [Warehouse-Native Medallion Architecture](../README.md) project.*
