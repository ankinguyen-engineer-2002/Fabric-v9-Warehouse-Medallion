# Onboarding Guide -- Adding a New Table to the ETL Pipeline
> A-to-Z guide for new DA/DE: create a table, register metadata, test, and run automatically in the pipeline
> No need to create a Stored Procedure, no need to modify the Pipeline

---

## Overview

The current architecture is **metadata-driven**: the pipeline reads `sp_registry` to know which tables to load, what type, and from where. Your job is simply:

```
1. Create a VIEW (containing the ETL logic)
2. INSERT 1 row into sp_registry (register the table)
3. Test manually
4. Done -- the pipeline automatically picks it up on the next run
```

**No need to**: create a Stored Procedure, edit pipeline JSON, or deploy anything else.

---

## Step 0 -- Determine the Layer

| Layer | When to use | Source reads from |
|-------|-------------|-------------------|
| **bronze** | Mirror raw data from source, no transformation | Lakehouse tables (via 3-part naming) |
| **bronze (ref_)** | Reference/dimension data that rarely changes | Lakehouse tables |
| **silver** | Join, transform, apply business rules from bronze | Bronze tables (same Warehouse) |
| **gold** | Aggregate, KPI, BI-ready from silver | Silver tables (same Warehouse) |

---

## Step 1 -- Choose Naming

### Table

| Layer | Pattern | Example |
|-------|---------|---------|
| bronze | `brz_{source_system}__{entity}` | `brz_saleshistory_afi__invoicedetail` |
| bronze (ref) | `ref_{entity}` | `ref_customer_account` |
| silver | `slv_{business_concept}` | `slv_actual_demand_monthly` |
| gold | `gld_fact_{subject}` or `gld_dim_{subject}` | `gld_fact_forecast_kpi` |

### View

| Layer | Pattern | Example |
|-------|---------|---------|
| bronze | `bronze.vw_brz_{name}` | `bronze.vw_brz_saleshistory_afi__invoicedetail` |
| bronze (ref) | `bronze.vw_ref_{name}` | `bronze.vw_ref_customer_account` |
| silver | `silver.vw_slv_{name}` | `silver.vw_slv_actual_demand_monthly` |
| gold | `gold.vw_gld_{name}` | `gold.vw_gld_fact_forecast_kpi` |

> **Rule**: Double underscores `__` separate the source system from the entity. Single underscores `_` separate words within a name.

---

## Step 2 -- Choose load_type

| load_type | Description | When to use | Additional requirements |
|-----------|-------------|-------------|------------------------|
| `overwrite` | Drop the old table, recreate from VIEW | Small data, or when you want a full refresh every time | (none) |
| `incremental` | Only INSERT new rows (based on watermark) | Large data, append-only, no updates to existing rows | `watermark_column` |
| `upsert` | DELETE old rows + INSERT new rows (based on PK) | Data with updates, needs merge | `primary_key` |
| `datekey` | DELETE + INSERT for a specific date | Fact tables by date | `date_key` |
| `daterange` | DELETE + INSERT for the most recent N days | Fact tables that need a refresh window | `date_key` + `date_range_days` |
| `identity` | Only INSERT rows with PK > current MAX | Append-only, auto-incrementing PK | `primary_key` |
| `cdc` | Apply change data capture | Source has CDC log | `primary_key` |
| `scd2` | Slowly Changing Dimension Type 2 | Dimensions that need history tracking | `primary_key` |

> **90% of cases** use `overwrite`. Only use other types when data is too large or there are special requirements.

---

## Step 3 -- Create the VIEW

The VIEW contains **all of the ETL logic**. The generic SP simply reads the VIEW and writes to the TABLE.

### 3a. Bronze -- mirror from source

```sql
CREATE OR ALTER VIEW bronze.vw_brz_{source}__{entity}
AS
SELECT *
FROM Enterprise_Lakehouse.{source_schema}.{source_table};
```

**Real-world example:**
```sql
CREATE OR ALTER VIEW bronze.vw_brz_saleshistory_afi__invoicedetail
AS
SELECT *
FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail;
```

> **Note**: `Enterprise_Lakehouse` is the Lakehouse name within the same Workspace. Use 3-part naming: `{Lakehouse}.{Schema}.{Table}`.

### 3b. Bronze (ref) -- reference data

```sql
CREATE OR ALTER VIEW bronze.vw_ref_customer_account
AS
SELECT
    CAST(CustomerNumber AS VARCHAR(20)) AS id_customer,
    CAST(CustomerName AS VARCHAR(200)) AS name_customer,
    CAST(City AS VARCHAR(100)) AS name_city,
    CAST(State AS VARCHAR(50)) AS code_state
FROM Enterprise_Lakehouse.SupplyChain_DW.DimCustomers;
```

> **Tip**: CAST columns to the correct data type and use aliases following the naming convention (`id_`, `name_`, `code_`, `qty_`, `amt_`, `dt_`, `is_`).

### 3c. Silver -- join + transform

```sql
CREATE OR ALTER VIEW silver.vw_slv_actual_demand_monthly
AS
SELECT
    inv.id_customer,
    cal.year_month,
    SUM(inv.qty_shipped) AS qty_demand
FROM silver.slv_invoice_detail_line_level inv
JOIN bronze.ref_calendar cal
    ON inv.dt_invoice = cal.dt_date
GROUP BY inv.id_customer, cal.year_month;
```

> **Silver views read from bronze tables** (or other silver tables). They do not read directly from the Lakehouse.

### 3d. Gold -- aggregate, KPI

```sql
CREATE OR ALTER VIEW gold.vw_gld_fact_forecast_kpi
AS
SELECT
    fc.year_month,
    fc.id_product,
    fc.qty_forecast,
    act.qty_actual,
    CASE WHEN fc.qty_forecast > 0
         THEN act.qty_actual * 1.0 / fc.qty_forecast
         ELSE NULL END AS pct_accuracy
FROM silver.slv_forecast_demand_monthly fc
LEFT JOIN silver.slv_actual_demand_monthly act
    ON fc.year_month = act.year_month
    AND fc.id_product = act.id_product;
```

---

## Step 4 -- Register in sp_registry

This is the **most important step**. INSERT 1 row into `meta.sp_registry` so the pipeline knows your table exists.

### Full template:

```sql
INSERT INTO meta.sp_registry (
    sp_name,              -- Always 'meta.usp_generic_load'
    view_name,            -- Name of the VIEW you just created (schema.view_name)
    target_schema,        -- Schema containing the TABLE (bronze/silver/gold)
    target_table,         -- Name of the TABLE to be created
    layer,                -- 'BRZ', 'REF', 'SLV', 'GLD'
    load_type,            -- overwrite/incremental/upsert/...
    frequency,            -- 'daily', 'monthly', 'hourly', 'weekly'
    scheduled_hour,       -- Run hour (UTC), typically 2
    execution_order,      -- Order within the layer (1 = default)
    is_active,            -- 1 = active, 0 = skip
    source_objects,       -- JSON array of source tables (for lineage)
    project,              -- Project name (e.g., 'supplychain', 'forecast')
    cron_expression,      -- Cron schedule (e.g., '0 2 * * *')
    -- Optional columns (set to NULL if not needed):
    depends_on,           -- JSON array of dependent silver tables
    watermark_column,     -- Column used as watermark (incremental)
    primary_key,          -- PK column (upsert/scd2/identity/cdc)
    date_key,             -- Date column (datekey/daterange)
    date_range_days       -- Number of days (daterange)
)
VALUES (
    'meta.usp_generic_load',
    '{schema}.vw_{table_name}',
    '{target_schema}',
    '{target_table}',
    '{LAYER}',
    '{load_type}',
    '{frequency}',
    2,
    1,
    1,
    '["source1", "source2"]',
    '{project}',
    '0 2 * * *',
    NULL, NULL, NULL, NULL, NULL
);
```

### Specific examples for each layer:

#### Bronze (overwrite, daily):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression
) VALUES (
    'meta.usp_generic_load',
    'bronze.vw_brz_wholesale_codis_afi__comast',
    'bronze', 'brz_wholesale_codis_afi__comast',
    'BRZ', 'overwrite', 'daily', 2, 1,
    1, '["Enterprise_Lakehouse.Wholesale_Codis_AFI.COMAST"]',
    'supplychain', '0 2 * * *'
);
```

#### Bronze ref (overwrite, monthly):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression
) VALUES (
    'meta.usp_generic_load',
    'bronze.vw_ref_customer_account',
    'bronze', 'ref_customer_account',
    'REF', 'overwrite', 'monthly', 2, 1,
    1, '["Enterprise_Lakehouse.SupplyChain_DW.DimCustomers"]',
    'supplychain', '0 2 1 * *'
);
```

#### Silver (overwrite, daily, with depends_on):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression, depends_on
) VALUES (
    'meta.usp_generic_load',
    'silver.vw_slv_actual_demand_monthly',
    'silver', 'slv_actual_demand_monthly',
    'SLV', 'overwrite', 'daily', 2, 1,
    1,
    '["silver.slv_invoice_detail_line_level","silver.slv_open_order_line_level","bronze.ref_calendar"]',
    'supplychain', '0 2 * * *',
    '["silver.slv_invoice_detail_line_level","silver.slv_open_order_line_level"]'
);
```

> **`depends_on`**: only needs to be declared for **silver** tables that depend on other silver tables. The pipeline automatically computes waves and runs in the correct order. Bronze and gold do not need depends_on.

#### Gold (overwrite, daily):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression
) VALUES (
    'meta.usp_generic_load',
    'gold.vw_gld_fact_forecast_kpi',
    'gold', 'gld_fact_forecast_kpi',
    'GLD', 'overwrite', 'daily', 2, 1,
    1,
    '["silver.slv_forecast_demand_monthly","silver.slv_actual_demand_monthly"]',
    'forecast', '0 2 * * *'
);
```

#### Incremental (with watermark):
```sql
INSERT INTO meta.sp_registry (
    sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, scheduled_hour, execution_order,
    is_active, source_objects, project, cron_expression,
    watermark_column
) VALUES (
    'meta.usp_generic_load',
    'bronze.vw_brz_supplychain_enh_1__demandforecastsnapshotdaily',
    'bronze', 'brz_supplychain_enh_1__demandforecastsnapshotdaily',
    'BRZ', 'incremental', 'daily', 2, 1,
    1,
    '["Enterprise_Lakehouse.SupplyChain_Enh_1.DemandForecastSnapshotDaily"]',
    'supplychain', '0 2 * * *',
    'SnapshotDate'
);
```

---

## Step 5 -- Test Manually

Run directly on the Warehouse to verify before the pipeline automatically loads:

```sql
-- Run once to create the TABLE and verify data
EXEC meta.usp_generic_load
    @target_schema = 'bronze',
    @target_table  = 'brz_wholesale_codis_afi__comast';
```

### Check the results:

```sql
-- 1. Was the table created?
SELECT COUNT(*) FROM bronze.brz_wholesale_codis_afi__comast;

-- 2. Was the log recorded?
SELECT TOP 1 * FROM meta.sp_run_history
WHERE sp_name = 'bronze.brz_wholesale_codis_afi__comast'
ORDER BY start_time DESC;

-- 3. Was sp_registry updated?
SELECT last_load_date, rows_loaded, next_run_time
FROM meta.sp_registry
WHERE target_table = 'brz_wholesale_codis_afi__comast';
```

> **If there is an error**: check `error_message` in `sp_run_history`. Common issues: VIEW has wrong column names, source table does not exist, data type mismatch.

---

## Step 6 (Optional but Recommended) -- Add DQ Rules

DQ rules check data quality. Add rules = INSERT 1 row into `dq_rules`. No pipeline changes needed.

> **Note (2026-04-18)**: DQ gates in `pl_sc_master` are currently **deactivated** for performance (~18 min vs ~27 min).
> Rules still exist and can be run manually via `pl_dq_check` or reactivated in Portal (right-click → Activate).
> Adding rules now is still recommended — they will be ready when DQ gates are reactivated.

### What DQ does when activated

```
bronze load → pl_dq_check runs all BRZ/REF rules → if CRITICAL fails → pipeline STOPS
silver load → pl_dq_check runs all SLV rules     → if CRITICAL fails → pipeline STOPS
gold load   → pl_dq_check runs all GLD rules     → if CRITICAL fails → pipeline STOPS
```

The DQ pipeline (`pl_dq_check`) reads `meta.dq_rules` dynamically — adding a rule = INSERT 1 row. No pipeline changes needed.

### Recommended: 2 rules per table

```sql
-- 1. Completeness: key column must not be NULL (CRITICAL = stops pipeline if fails)
INSERT INTO meta.dq_rules (
    rule_id, rule_name, target_schema, target_table,
    check_type, column_name, severity, is_active, layer
) VALUES (
    (SELECT ISNULL(MAX(rule_id),0)+1 FROM meta.dq_rules),
    'brz_comast id_customer not null',
    'bronze', 'brz_wholesale_codis_afi__comast',
    'completeness', 'id_customer', 'CRITICAL', 1, 'BRZ'
);

-- 2. Row count: minimum expected rows (WARNING = logs only, does not stop pipeline)
INSERT INTO meta.dq_rules (
    rule_id, rule_name, target_schema, target_table,
    check_type, severity, threshold, is_active, layer
) VALUES (
    (SELECT ISNULL(MAX(rule_id),0)+1 FROM meta.dq_rules),
    'brz_comast min 100K rows',
    'bronze', 'brz_wholesale_codis_afi__comast',
    'row_count', 'WARNING', 100000, 1, 'BRZ'
);
```

### Severity behavior

| Severity | On FAIL | When to use |
|----------|---------|-------------|
| **CRITICAL** | Pipeline **stops** — downstream layers do not run | Key columns NULL, table empty |
| **WARNING** | Logged to `dq_results`, pipeline **continues** | Row count slightly low |

### All check types

| check_type | What it checks | Required columns |
|------------|----------------|------------------|
| `completeness` | Column NOT NULL % ≥ threshold | `column_name` |
| `row_count` | Row count ≥ threshold | `threshold` |
| `uniqueness` | No duplicates in column | `column_name` |
| `freshness` | Data loaded within N hours | `threshold` |
| `referential_integrity` | FK exists in parent | `params` (SQL) |
| `validity` | Values in expected set | `params` (SQL) |
| `custom_sql` | Any SQL check | `params` (SQL returning 0=pass) |

### How to check DQ results

```sql
SELECT rule_id, status, actual_value, expected_value, error_detail
FROM meta.dq_results
WHERE target_table = 'brz_wholesale_codis_afi__comast'
ORDER BY check_time DESC;
```

---

## Step 7 -- Done! The Pipeline Automatically Picks It Up

**No further action needed.** On the next pipeline run:

1. `pl_sc_master` discovers your project via `SELECT DISTINCT project FROM sp_registry`
2. `pl_sc_mart` invokes bronze -> silver -> gold for your project
3. `pl_sc_bronze` Lookup reads `sp_registry WHERE project=@project` -> finds your new table -> loads it
4. `pl_sc_silver` computes waves -> recalculates the DAG -> runs in the correct order
5. `pl_sc_gold` Lookup -> loads gold tables
6. `usp_finalize_pipeline` automatically rebuilds lineage (including the new table)

> **Health check**: After adding a table, run `python3 scripts/health_check.py` to verify (49 checks).

### Smart skip:
- If `frequency = 'daily'` and `cron = '0 2 * * *'`: runs every day
- If `frequency = 'monthly'` and `cron = '0 2 1 * *'`: automatically skips 29/30 days

---

## Summary Checklist

```
[ ] 1. Determine the layer: bronze / silver / gold
[ ] 2. Name according to the naming convention
[ ] 3. Choose load_type (overwrite is the default)
[ ] 4. CREATE VIEW with ETL logic
[ ] 5. INSERT into meta.sp_registry
[ ] 6. EXEC meta.usp_generic_load -- test it
[ ] 7. Verify: SELECT COUNT, sp_run_history, sp_registry
[ ] 8. (Optional) INSERT DQ rules
[ ] 9. (Optional) Declare depends_on (silver only)
[ ] Done -- the pipeline automatically loads on the next run
```

---

## Cron Cheat Sheet

| Cron | Meaning |
|------|---------|
| `0 2 * * *` | 2AM every day |
| `0 2 * * 1` | 2AM every Monday |
| `0 2 * * 1-5` | 2AM weekdays |
| `0 2 1 * *` | 2AM on the 1st of every month |
| `0 */4 * * *` | Every 4 hours |
| `*/15 6-22 * * 1-5` | Every 15 minutes, 6AM-10PM, weekdays |

---

## FAQ

### Q: Do I need to create a separate Stored Procedure?
**No.** `meta.usp_generic_load` handles all 8 load patterns. You only need to create a VIEW and register it.

### Q: Do I need to modify the pipeline?
**No.** The pipeline reads `sp_registry` dynamically (Lookup query). New tables appear automatically.

### Q: What if my silver table depends on another silver table?
Declare `depends_on` in `sp_registry`. The pipeline computes waves automatically -- tables with no dependencies run first (wave 0), dependent tables run after (wave 1, 2, ...).

### Q: How do I know if my table ran successfully?
```sql
SELECT sp_name, status, rows_affected, start_time, duration_seconds
FROM meta.sp_run_history
WHERE sp_name = '{schema}.{table_name}'
ORDER BY start_time DESC;
```

### Q: How do I temporarily disable a table from running?
```sql
UPDATE meta.sp_registry SET is_active = 0
WHERE target_table = '{table_name}';
```

### Q: How do I completely remove a table?
```sql
-- 1. Remove from registry
DELETE FROM meta.sp_registry WHERE target_table = '{table_name}';
-- 2. Remove DQ rules (if any)
DELETE FROM meta.dq_rules WHERE target_table = '{table_name}';
-- 3. Drop TABLE + VIEW
DROP TABLE IF EXISTS {schema}.{table_name};
DROP VIEW IF EXISTS {schema}.vw_{table_name};
```

### Q: What is `source_objects` used for?
It is used to **automatically build lineage** (the `sp_lineage` table). Enter the exact names of the tables that your VIEW selects from. Format as a JSON array: `'["schema.table1","schema.table2"]'`.
