<div align="center">

# Hybrid Medallion Architecture

### Enterprise Data Warehouse Template on Microsoft Fabric

<br/>

![PLATFORM](https://img.shields.io/badge/PLATFORM-Microsoft_Fabric-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![LANGUAGE](https://img.shields.io/badge/LANGUAGE-Pure_T--SQL-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![PATTERN](https://img.shields.io/badge/PATTERN-Medallion-6C3483?style=for-the-badge)
![BI](https://img.shields.io/badge/BI-Direct_Lake-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

![PIPELINES](https://img.shields.io/badge/PIPELINES-7-2196F3?style=flat-square)
![OBJECTS](https://img.shields.io/badge/OBJECTS-90-4CAF50?style=flat-square)
![LOAD PATTERNS](https://img.shields.io/badge/LOAD_PATTERNS-8-FF9800?style=flat-square)
![DQ RULES](https://img.shields.io/badge/DQ_RULES-54-E91E63?style=flat-square)
![RUNTIME](https://img.shields.io/badge/RUNTIME-~31_min-00BCD4?style=flat-square)

<br/>

A production-ready **metadata-driven** data warehouse framework on Microsoft Fabric.<br/>
Pure T-SQL stored procedures. No Notebooks. No PySpark. No Lakehouse ETL.

[Architecture](#architecture) · [Pipelines](#pipeline-architecture) · [Control Plane](#control-plane) · [Load Patterns](#generic-sp-architecture) · [Onboarding](#onboarding)

<br/>

---

</div>

## Architecture

```
Enterprise_Data (upstream)
  └─ Source products (EDW, Codis, MasterData, Customers)

SupplyChain Dev Workspace
  ├─ BRONZE ─── Enterprise_Lakehouse (OneLake shortcuts = logical Bronze)
  │             SupplyChain_Lakehouse (EDW supplement dataflows)
  │
  ├─ SILVER ─── Processing_Warehouse
  │             ├── Staging          (exception-only persistence)
  │             ├── ReferenceMaster  (domain reference data)
  │             ├── DomainSchema_1   (business transformations)
  │             ├── DomainSchema_N   (N domain schemas, PascalCase)
  │             └── Meta             (control plane: registry, DQ, lineage, DAG)
  │
  └─ GOLD ──── Gold_Warehouse
               └── ServingSchema    (physical tables for Direct Lake)
```

### Medallion Layer Design

| Layer | Implementation | Pattern |
|---|---|---|
| **Bronze** | OneLake shortcuts in Lakehouse | Logical access — no mandatory local copy. Stage only for EDW supplement, unstable SLA, or snapshot consistency |
| **Silver** | Domain schemas in Processing Warehouse | PascalCase schemas grouped by business process. Each table has a paired `VIEW` defining transformation logic |
| **Gold** | Dedicated Gold Warehouse | Separate Fabric Warehouse for BI serving. Direct Lake semantic models read physical Gold tables |
| **Meta** | Control plane in Processing Warehouse | 20 tables, 5 views, 13 SPs, 3 functions. Drives all orchestration, quality, lineage, scheduling |

---

## Pipeline Architecture

```
pl_master
  ├─ log_start (usp_LogPipelineRun)
  ├─ Lookup DISTINCT project FROM registry
  ├─ ForEach project (parallel batch=10)         ◄── MULTI-MART
  │    └─ pl_mart (per project)
  │         ├─ pl_staging   (EDW refresh + REF load with smart skip)
  │         ├─ pl_silver    (compute DAG waves → sequential dispatch)
  │         │    └─ pl_silver_wave (parallel batch=8 within wave)
  │         └─ pl_gold      (cross-DB CTAS to Gold Warehouse)
  └─ finalize (rebuild lineage + log summary)

pl_dq_check (standalone)
  └─ Lookup active DQ rules → ForEach batch=5 → usp_CheckDqSingle
```

### Key Pipeline Features

| Feature | How |
|---|---|
| **Multi-mart** | ForEach DISTINCT project from registry. Add a new project = registry INSERT only, no pipeline changes |
| **Silver DAG** | `usp_ComputeSilverWaves` builds dependency graph → waves execute sequentially, tables within wave parallel |
| **Smart skip** | Lookup SQL filters `WHERE next_run_time <= GETUTCDATE()`. Monthly REF tables skip on daily runs |
| **Gold cross-DB** | Script activity runs CTAS in Gold Warehouse, reading from Processing WH via 3-part naming |
| **DQ gates** | Per-rule DQ engine. CRITICAL → THROW (stops pipeline). WARNING → log only |

---

## Generic SP Architecture

**1 stored procedure handles all table loads.** Load pattern determined by `load_type` in the registry.

| Pattern | Description | Use Case |
|---|---|---|
| `overwrite` | DROP + CTAS | Full refresh (default for most tables) |
| `incremental` | INSERT WHERE watermark > last | Append-only sources |
| `upsert` | DELETE matching PKs + INSERT | Update + insert |
| `datekey` | DELETE today + INSERT today | Daily partition reload |
| `daterange` | DELETE N days + INSERT N days | Rolling window |
| `identity` | INSERT WHERE PK > MAX | Auto-increment append |
| `cdc` | DELETE changed + INSERT | Change data capture |
| `scd2` | Close old + insert new version | Slowly changing dimensions |

```sql
-- Load any table: just pass schema + table name
EXEC Meta.usp_GenericLoad @target_schema='SalesHistory', @target_table='InvoiceWeekly';
-- Framework handles: read config → execute pattern → log → update watermark → set next_run_time
```

---

## Control Plane

| Component | Object | Description |
|---|---|---|
| **Registry** | `AssetRegistryV10` | Canonical registry: asset, layer, access mode, load type, frequency, cron, project, dependencies |
| **Loader** | `usp_GenericLoad` | 8 load patterns, reads from registry, executes CTAS/INSERT |
| **Logger** | `usp_LogRun` | Start/end UTC+CST, rows, status, retry 3x on snapshot conflict |
| **Finalizer** | `usp_FinalizePipeline` | Rebuild lineage + summarize pipeline run |
| **Lineage** | `usp_BuildLineage` | Auto-parse source_objects → edge graph |
| **DAG** | `usp_ComputeSilverWaves` | Iterative wave assignment from dependency graph |
| **DQ** | `usp_CheckDqSingle` | Per-rule DQ: completeness, row_count, uniqueness, freshness |
| **Smart Skip** | `ufn_should_run` | next_run_time check (daily/monthly/weekly awareness) |
| **Cron** | `ufn_cron_is_due` | 5-field cron parser (minute, hour, day, month, weekday) |
| **Timezone** | `ufn_utc_to_cst` | DST-aware UTC → CST conversion |
| **Dictionary** | `vw_TableDictionary` | Enterprise-compatible 63-column metadata adapter |
| **Compatibility** | `vw_sp_registry` | v9-compatible view for pipeline Lookups |

---

## Adding a New Table

### 3 Steps

```sql
-- 1. Register
INSERT INTO Meta.AssetRegistryV10 (asset_id, canonical_layer, access_mode,
    physical_schema, physical_object, load_type, frequency, cron_expression,
    project, is_active, source_objects, legacy_view_name)
VALUES ('source.new_table', 'DomainSilver', 'WarehouseTransform',
    'MySchema', 'MyTable', 'overwrite', 'daily', '0 2 * * *',
    'myproject', 1, '["Staging.SourceTable"]', 'MySchema.vw_MyTable');

-- 2. Create view (transformation logic)
CREATE VIEW MySchema.vw_MyTable AS
SELECT col1, col2, SUM(qty) AS total FROM Staging.SourceTable GROUP BY col1, col2;

-- 3. Test
EXEC Meta.usp_GenericLoad @target_schema='MySchema', @target_table='MyTable';
```

Framework auto-handles: logging, watermark, next_run_time, lineage, DQ eligibility.

---

## Onboarding

### First 30 Minutes

1. **Access**: Request Workspace Viewer on the DEV workspace
2. **Connect**: SQL endpoint → Processing Warehouse
3. **Explore**: `SELECT * FROM Meta.AssetRegistryV10` — see all registered assets
4. **DAG**: `SELECT * FROM Meta.SilverDagWaveRuntime` — see wave assignments
5. **Health**: `SELECT TOP 20 * FROM Meta.RunLog ORDER BY start_time_utc DESC` — recent runs
6. **Docs**: This README → then `02_Architect_*/14_*_runbook.md` for implementation detail

### Adding a New Data Mart

1. Insert new assets with `project = 'new_project_name'` in registry
2. Create views for each asset
3. Run `EXEC Meta.usp_ComputeSilverWaves` to rebuild DAG
4. Trigger `pl_master` — ForEach will automatically pick up the new project
5. Create a branch named after the project for project-specific docs

---

## Fabric Constraints & Workarounds

| Constraint | Workaround |
|---|---|
| No DEFAULT / IDENTITY | Set in SP / ROW_NUMBER() |
| ForEach inside ForEach | Parent-child pipeline pattern |
| Warehouse Lookup | LakehouseTableSource + cross-DB 3-part name |
| Concurrent write conflicts | SP retry 3x + WAITFOR DELAY |
| BIT type unstable | Use INT (0/1) |
| datetime in CTAS | CAST(GETUTCDATE() AS DATETIME2(6)) |
| Decimal date columns (CODIS) | CAST(BIGINT) → VARCHAR → TRY_CONVERT(DATE) |
| Table-valued functions | Not supported — use scalar |

---

## Project Branches

| Branch | Purpose |
|---|---|
| `main` | Architecture template — generic, reusable |
| `sc_forecast` | Supply Chain Forecast Accuracy — full implementation with data, pipelines, connection IDs |
| `{domain}_*` | Future domain branches (add 1 branch per new data mart / project) |

---

## Tech Stack

| | Technology |
|---|---|
| Platform | Microsoft Fabric F256 |
| Compute | Fabric Warehouse (Serverless T-SQL) |
| Storage | OneLake (Delta Lake) |
| Orchestration | Fabric Data Pipelines (7 pipelines) |
| BI | Power BI Direct Lake |
| DQ | Custom T-SQL DQ engine (4 check types, 54 rules) |
| Lineage | Auto-built from metadata |
| Monitoring | Streamlit lineage explorer (auto-refresh via GitHub Actions) |
| CI/CD | GitHub + Fabric REST API |

---

<div align="center">

**Vietnam Data Hub** · Ashley Furniture Industries · DataHub VN Team

Built with Microsoft Fabric · Architected by Aric Nguyen

</div>
