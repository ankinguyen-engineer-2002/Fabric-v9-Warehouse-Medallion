# Projects — Live Workspace Detail

This folder contains **per-project live state catalogs** of what's actually built and running in the Microsoft Fabric workspace `SupplyChain Dev` (`c8d9fc83-18b6-4e1d-8264-0b49eed36fe0`).

Each project folder is a complete inventory: real table names, row counts, IDs, ETL DDL, pipeline definitions, semantic model details, lineage. Generated from live workspace scans.

> **Boundary:** Everything outside this `projects/` folder in `02_Architect_v10_May/` is generic template content — do not put project-specific detail there.

## Project Index

| Folder | Mart | Gold Schema | Status | Last scan |
|--------|------|-------------|--------|-----------|
| [forecast/](forecast/README.md) | Forecast Accuracy | `ForecastAccuracy_DW` | LIVE | 2026-05-06 |
| *(future)* `invhealth/` | Inventory Health | `InventoryHealth_DW` | — | — |

## Adding a new project

1. Create folder `02_Architect_v10_May/projects/<name>/`
2. Copy structure from `forecast/` (8 docs + `etl/` subfolder)
3. Run live scan via Fabric MCP + pyodbc against Processing/Gold WH
4. Fill each doc with concrete data
5. Add row to "Project Index" table above

## Per-project structure

```
<project_name>/
├── README.md            project card: status + infra snapshot + quick links
├── 00_workspace.md      workspace, WH IDs, SQL endpoint, auth tokens
├── 10_bronze.md         Bronze layer — Lakehouses + EDW supplement feeds
├── 20_silver.md         Silver layer — domain schemas, tables, ETL logic
├── 30_gold.md           Gold layer — Fact/Dim, cross-DB serving
├── 40_pipelines.md      pipelines — IDs, DAG, schedule, runtime
├── 50_semantic.md       semantic model — tables, measures, RLS
├── 60_lineage.md        lineage edges + Gold → SemanticModel
└── etl/
    ├── staging_ddl.sql
    ├── silver_views.sql
    ├── gold_views.sql
    └── meta_sps.sql
```
