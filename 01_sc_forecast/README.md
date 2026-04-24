# 01 — Supply Chain Forecast

> SupplyChain Warehouse v9 | Ashley Furniture Vietnam
> Status: **Production** (daily 2AM UTC+7)

Project-specific documentation for **Supply Chain Demand Forecasting**. For shared architecture, patterns, and naming conventions, see the [root README](../README.md).

---

## Current Source State (2026-04-24)

4 bronze tables temporarily read from `_edw` supplement (EDW via Lakehouse `_ver2`) instead of Enterprise_Lakehouse. Reason: EL has incomplete data for these tables.

| Table | EL Rows | EDW Rows | Gap | EL Status |
|-------|---------|----------|-----|-----------|
| brz_saleshistory_afi__invoicedetail | 126.6M | 87.7M | EL has full history since 2017 | **Ready** |
| brz_saleshistory_afi__invoiceheader | 4.1M | 24.7M | EL missing 2023-01 to 2025-09 | **Not Ready** |
| brz_demandforecastsnapshotdaily | 1.3B | 42.4M | EL has 3mo snapshots, need 3yr | **Not Ready** |
| ref_product | 373K | 379K | ~1.6% diff | **Ready** |

When EL is complete → rollback via [edw_source_swap.md](docs/operations/edw_source_swap.md).

---

## Documentation

### Project-Specific
| # | Doc | Description |
|---|-----|-------------|
| 1 | [01_architecture.md](docs/01_architecture.md) | All objects: names, row counts, pipeline IDs, source mappings |
| 2 | [02_setup.md](docs/02_setup.md) | Implementation log: Spark-to-T-SQL conversions, bugs, fixes |
| 3 | [03_pipeline.md](docs/03_pipeline.md) | Execution trace: SP names, durations, wave assignments |
| 4 | [04_v8_vs_v9_comparison.md](docs/04_v8_vs_v9_comparison.md) | V8 (notebook) vs V9 (warehouse) migration comparison |

### Project Operations
| Doc | Description |
|-----|-------------|
| [edw_source_swap.md](docs/operations/edw_source_swap.md) | EDW source swap + rollback guide (temporary) |

### Shared Operations (all projects)
| # | Doc | Description |
|---|-----|-------------|
| 1 | [01_runbook.md](../docs/01_operations/01_runbook.md) | Pipeline troubleshooting, re-run, escalation |
| 2 | [02_onboarding.md](../docs/01_operations/02_onboarding.md) | Add new tables (2 SQL statements) |
| 3 | [03_scheduling.md](../docs/01_operations/03_scheduling.md) | Cron, smart skip, concurrency |
| 4 | [04_alerting.md](../docs/01_operations/04_alerting.md) | Alerting design (blocked by IT) |
| 5 | [05_generic_sp_migration.md](../docs/01_operations/05_generic_sp_migration.md) | Migration: 28 per-table SPs to 1 generic SP |
| 6 | [06_timezone_sync.md](../docs/01_operations/06_timezone_sync.md) | UTC + CST + VN timezone sync |
| 7 | [07_sqlproj_validation.md](../docs/01_operations/07_sqlproj_validation.md) | .sqlproj build validation |

### Enterprise & Scale
| # | Doc | Description |
|---|-----|-------------|
| 1 | [01_roadmap.md](enterprise/01_roadmap.md) | 4-phase enterprise roadmap, score 8.2/10 |
| 2 | [02_multi_mart_scale.md](enterprise/02_multi_mart_scale.md) | N marts parallel, cross-mart dependencies |
| 3 | [03_fabric_vs_enterprise.md](enterprise/03_fabric_vs_enterprise.md) | Enterprise ETL framework comparison (US) |

---

## Quick Start

### Add a new bronze table
```sql
-- 1. Create view (ETL logic)
CREATE OR ALTER VIEW bronze.vw_brz_{name} AS
SELECT * FROM Enterprise_Lakehouse.{schema}.{table};

-- 2. Register in metadata
INSERT INTO meta.sp_registry (sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, is_active, source_objects, project, cron_expression)
VALUES ('meta.usp_generic_load', 'bronze.vw_brz_{name}',
    'bronze', 'brz_{name}', 'BRZ', 'overwrite', 'daily', 1,
    '["Enterprise_Lakehouse.{schema}.{table}"]', 'supplychain', '0 2 * * *');
-- Pipeline auto picks up next run. No pipeline changes needed.
```

### Run pipeline manually
Trigger `pl_sc_master` from Fabric Portal.

### Troubleshoot a failure
See [01_runbook.md](../docs/01_operations/01_runbook.md).

---

*Shared architecture, patterns, constraints → [root README](../README.md) | Templates → [docs/02_templates/](../docs/02_templates/)*
