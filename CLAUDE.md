# CLAUDE.md — Project Instructions for AI Assistants
> SupplyChain Warehouse v9 — Microsoft Fabric, Pure T-SQL, Metadata-Driven
> Last updated: 2026-04-18 | Score: 8.2/10 | Enterprise mapping: ~91%

---

## Project Overview

Warehouse-native medallion architecture on Microsoft Fabric. Pure T-SQL, no Notebooks/PySpark.
- **~85 objects**: 4 schemas (bronze/silver/gold/meta), 28 data tables, 10 meta tables, 30 views, 10 SPs, 3 functions
- **6 pipelines**: parent-child DAG orchestration, DQ gates between layers
- **1 generic SP** handles 8 load patterns for all 28 tables
- **Auto-trigger**: daily 2AM UTC+7

---

## Key Architecture Rules

### DO
- Use `DATETIME2(6)` everywhere (never `datetime`)
- Use `INT` for booleans (never `BIT`)
- Use `VARCHAR(n)` with explicit length (never default)
- Use `sp_executesql` with `NVARCHAR` for dynamic SQL
- Use 3-part naming for cross-DB: `Enterprise_Lakehouse.Schema.Table`
- Use `LakehouseTableSource` for Pipeline Lookups (not WarehouseSource)
- Use parent-child pipeline pattern for nested iteration
- Add retry 3x/2s in SPs that write to shared tables
- Add `_load_dt` column (DATETIME2(6)) to every table
- Register new tables in `sp_registry` (2 SQL statements: CREATE VIEW + INSERT)
- Filter pipeline Lookups: `AND (next_run_time IS NULL OR next_run_time <= GETUTCDATE())`

### DON'T
- Don't create per-table SPs — use `meta.usp_generic_load`
- Don't use ForEach inside Until (Fabric error)
- Don't use recursive CTEs (not supported)
- Don't use `CURSOR` or `@@FETCH_STATUS` (not supported)
- Don't use `TRIM()` on numeric types
- Don't convert SQL to `$(SqlCmdVariable)` until Azure DevOps + sqlpackage is ready
- Don't use WarehouseSource in Pipeline Lookup activities
- Don't set batch > 6 for bronze ForEach (snapshot conflicts)

---

## Connection Details

| Resource | ID/Endpoint |
|----------|-------------|
| Tenant | `5a9d9cfd-c32e-4ac1-a9ed-fe83df4f9e4d` |
| Workspace | `c8d9fc83-18b6-4e1d-8264-0b49eed36fe0` |
| Warehouse | `e146ffe2-d907-46a7-9b7e-3e739a31b24e` |
| SQL Endpoint | `7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com` |
| Semantic Model | `a52841ee-d853-46df-b2f7-2a2cc4493d60` |

### Token Commands
```bash
# Warehouse (pyodbc)
az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv

# Fabric REST API
az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv

# Power BI API (SM refresh)
az account get-access-token --resource https://analysis.windows.net/powerbi/api --query accessToken -o tsv
```

### Python + pyodbc Connection
```python
import pyodbc, struct, subprocess, json

result = subprocess.run(
    ['az', 'account', 'get-access-token', '--resource', 'https://database.windows.net/', '--output', 'json'],
    capture_output=True, text=True)
token = json.loads(result.stdout)['accessToken']
token_bytes = token.encode('UTF-16-LE')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

server = '7woj2wroypauvkpn72b56t46ju-qp6ntsfwdaou5atebne65u3p4a.datawarehouse.fabric.microsoft.com'
conn = pyodbc.connect(
    f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={server};'
    f'DATABASE=SupplyChain_Warehouse;Encrypt=yes;TrustServerCertificate=no;',
    attrs_before={1256: token_struct})
```

---

## Proven Patterns (use these, don't reinvent)

### 1. Generic SP Load — adding a new table
```sql
-- Step 1: Create view (ETL logic)
CREATE OR ALTER VIEW silver.vw_slv_new_table AS
SELECT ... FROM bronze.brz_source JOIN bronze.ref_dim ...;

-- Step 2: Register
INSERT INTO meta.sp_registry (sp_name, view_name, target_schema, target_table,
    layer, load_type, frequency, is_active, source_objects, depends_on, cron_expression, project)
VALUES ('silver.slv_new_table', 'silver.vw_slv_new_table', 'silver', 'slv_new_table',
    'SLV', 'overwrite', 'daily', 1,
    '["bronze.brz_source","bronze.ref_dim"]', '["silver.slv_upstream"]',
    '0 2 * * *', 'supplychain');
-- Done. Pipeline auto picks up next run.
```

### 2. DQ Rule — adding a check
```sql
INSERT INTO meta.dq_rules (rule_id, rule_name, target_schema, target_table,
    check_type, column_name, severity, threshold, is_active, layer)
VALUES (31, 'new_table_pk_unique', 'silver', 'slv_new_table',
    'uniqueness', 'id_primary_key', 'CRITICAL', 0, 1, 'SLV');
-- 0 = expect 0 duplicates. CRITICAL = pipeline stops on fail.
```

### 3. Pipeline Lookup — query warehouse from pipeline
```json
{
  "source": {
    "type": "LakehouseTableSource",
    "sqlReaderQuery": "SELECT target_schema, target_table FROM SupplyChain_Warehouse.meta.sp_registry WHERE ..."
  },
  "connectionSettings": {
    "type": "Lakehouse",
    "typeProperties": { "artifactId": "62a3081e-..." }
  }
}
```

### 4. Snapshot Conflict Retry (SP-level)
```sql
DECLARE @retry INT = 0, @done INT = 0;
WHILE @retry < 3 AND @done = 0
BEGIN
    BEGIN TRY
        INSERT/UPDATE ...;
        SET @done = 1;
    END TRY
    BEGIN CATCH
        SET @retry = @retry + 1;
        WAITFOR DELAY '00:00:02';
    END CATCH
END
```

### 5. Fabric REST API — deploy pipeline
```bash
TOKEN=$(az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv)
curl -X POST "https://api.fabric.microsoft.com/v1/workspaces/$WS_ID/items" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"displayName":"pl_name","type":"DataPipeline","definition":{"parts":[...]}}'
```

---

## Methods That Failed (don't retry these)

| Approach | Why it failed | Use instead |
|----------|-------------|-------------|
| WarehouseSource in Lookup | "Failed to open resource" | LakehouseTableSource + cross-DB |
| ForEach inside Until | BadRequest error | Parent-child pipeline |
| Recursive CTE | Not supported in Fabric WH | WHILE loop in SP |
| WHILE + sp_executesql (DQ) | Only 1 iteration executes | Pipeline ForEach + single-rule SP |
| Variables in distributed SQL | "Not supported in distributed mode" | sp_executesql with @parameters |
| CURSOR / @@FETCH_STATUS | Not supported | WHILE + TOP 1 WHERE id > @current |
| `datetime` in CTAS | Type error | CAST(... AS DATETIME2(6)) |
| Power Automate HTTP trigger | Needs Premium license | Pending IT approval |
| Teams Incoming Webhook | No channel creation permission | Pending IT approval |
| Graph API Mail.Send | 403 Access Denied | Pending admin consent |
| Data Activator Reflex | 401 OneLake events | Pending IT approval |

---

## Current Blockers

| Item | Blocked by | What's needed |
|------|-----------|---------------|
| **Alerting** | IT permissions | Admin consent for Mail.Send on app `616bb922`, OR Teams channel, OR Power Automate Premium |
| **CI/CD** | Azure DevOps access | Not yet granted. Don't convert SQL to `$(...)` until ready |

---

## File Map

| File | Purpose |
|------|---------|
| `FULL_CONTEXT.md` | Master context: all IDs, schemas, code, history |
| `README.md` | Public documentation (13 sections) |
| `task.md` | Roadmap progress tracker |
| `Fabric_Architect/future_roadmap.md` | Score, strengths, weaknesses, 4-phase roadmap |
| `Fabric_Architect/runbook_operations.md` | Operations: errors, re-run, escalation |
| `Fabric_Architect/alerting_setup_guide.md` | Alerting design (blocked by IT) |
| `Fabric_Architect/new_table_onboarding_guide.md` | Add new table (2 SQL statements) |
| `Fabric_Architect/v9_setup_supplychain.md` | Implementation log with all DDL |
| `Fabric_Architect/multi_mart_scale_architecture.md` | Multi-mart parallel design |
| `Fabric_Architect/scheduling_and_concurrency.md` | Scheduling, cron, concurrency |
| `Fabric_Architect/template_architecture.md` | Generic architecture reference |
