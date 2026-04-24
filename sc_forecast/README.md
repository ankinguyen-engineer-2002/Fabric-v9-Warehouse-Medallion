# Supply Chain Forecast — sc_forecast

> Du an cu the: SupplyChain Warehouse v9 | Ashley Furniture Vietnam
> Status: **Production** (daily 2AM UTC+7)

Subfolder nay chua tai lieu rieng cho du an **Supply Chain Demand Forecasting**. Kien truc chung, patterns, naming conventions → xem [README.md goc](../README.md).

---

## Current Source State (2026-04-23)

4 bronze tables tam thoi doc tu `_edw` (EDW via Lakehouse `_ver2`) thay vi Enterprise_Lakehouse. Ly do: EL chua day du data.

| Bang | EL Rows | EDW Rows | Chenh lech |
|------|---------|----------|------------|
| brz_saleshistory_afi__invoicedetail | 35.4M | 87.7M | EL thieu 60% |
| brz_saleshistory_afi__invoiceheader | 4.1M | 24.7M | EL thieu 83% |
| brz_supplychain_enh_1__demandforecastsnapshotdaily | 1.3B (full) | 42.4M (41 snapshots) | DF filter |
| ref_product | 373K | 379K | ~1.6% |

Khi EL day du → rollback theo [edw_source_swap.md](docs/operations/edw_source_swap.md).

---

## Documentation

### Architecture & Setup (chi tiet rieng cho forecast)
| Doc | Mo ta |
|-----|-------|
| [architecture.md](docs/architecture.md) | Toan bo objects: ten, row counts, pipeline IDs, source mapping |
| [setup.md](docs/setup.md) | Implementation log: Spark→T-SQL, bugs, fixes, DDL |
| [pipeline.md](docs/pipeline.md) | Execution trace: SP names, durations, wave assignments |
| [v8_vs_v9_comparison.md](docs/v8_vs_v9_comparison.md) | So sanh v8 (notebook) vs v9 (warehouse), source mapping |

### Operations (rieng cho forecast)
| Doc | Mo ta |
|-----|-------|
| [edw_source_swap.md](docs/operations/edw_source_swap.md) | **Doi source EDW ↔ EL: swap + rollback** |

### Operations (chung — ap dung moi project)
| Doc | Mo ta |
|-----|-------|
| [runbook.md](../docs/operations/runbook.md) | Pipeline errors, re-run, escalation |
| [onboarding.md](../docs/operations/onboarding.md) | Them bang moi (2 SQL statements) |
| [scheduling.md](../docs/operations/scheduling.md) | Cron, smart skip, concurrency |
| [alerting.md](../docs/operations/alerting.md) | Alerting design (blocked by IT) |
| [generic_sp_migration.md](../docs/operations/generic_sp_migration.md) | Migration 28 SPs → 1 generic SP |
| [sqlproj_validation.md](../docs/operations/sqlproj_validation.md) | .sqlproj build validation |
| [timezone_sync.md](../docs/operations/timezone_sync.md) | UTC + CST + VN timezone |

### Enterprise & Scale
| Doc | Mo ta |
|-----|-------|
| [roadmap.md](enterprise/roadmap.md) | 4-phase enterprise roadmap, score 8.2/10 |
| [multi_mart_scale.md](enterprise/multi_mart_scale.md) | N marts parallel, cross-mart deps |
| [fabric_vs_enterprise.md](enterprise/fabric_vs_enterprise.md) | So sanh voi Enterprise ETL framework (US) |

---

## Quick Start

### Them bang bronze moi
```sql
-- 1. Tao view
CREATE OR ALTER VIEW bronze.vw_brz_{name} AS
SELECT * FROM Enterprise_Lakehouse.{schema}.{table};

-- 2. Dang ky
INSERT INTO meta.sp_registry (sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, is_active, source_objects, project, cron_expression)
VALUES ('meta.usp_generic_load', 'bronze.vw_brz_{name}',
    'bronze', 'brz_{name}', 'BRZ', 'overwrite', 'daily', 1,
    '["Enterprise_Lakehouse.{schema}.{table}"]', 'supplychain', '0 2 * * *');
```

### Chay pipeline manual
Trigger `pl_sc_master` tu Fabric Portal.

### Pipeline bi loi
Xem [runbook.md](../docs/operations/runbook.md).

---

*Kien truc chung, patterns, constraints → xem [README goc](../README.md) va [templates](../docs/templates/).*
