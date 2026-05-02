# .sqlproj Validation Guide
> Build-time SQL validation: catch errors before deploy, don't wait until runtime
> 3 approaches: from lightweight to full Enterprise

---

## Current Problem

v9 **has no build-time validation**. Errors are only discovered when the pipeline runs:

```
Developer edits VIEW → push Git → deploy
    ↓
Pipeline trigger → SP runs CTAS from VIEW
    ↓
RUNTIME ERROR: "Invalid column name 'xyz'"
    ↓
Table fail → error discovered (too late)
```

Enterprise team (US) has .sqlproj validation — errors are discovered **before deploy**:

```
Developer edits VIEW → push Git → Azure Pipeline build
    ↓
DacFx reads all .sql files → validate references
    ↓
BUILD FAIL: "unresolved reference to [xyz]"
    ↓
No deploy → developer fixes first (early)
```

---

## How Enterprise Currently Does It

### Structure

```
data-edw-fabric/
├── Source_Data/
│   └── Source_Data.sqlproj          ← 75 source schemas
├── SupplyChain_Warehouse/
│   └── SupplyChain_Warehouse.sqlproj
├── ETL_Framework/
│   └── ETL_Framework.sqlproj
├── Retail_Warehouse/
│   └── Retail_Warehouse.sqlproj
├── ... (17 .sqlproj total)
└── azure-pipelines/
    └── azure-pipelines.yml          ← CI pipeline
```

### ProjectReference — cross-database validation

```xml
<!-- SupplyChain_Warehouse.sqlproj -->
<ProjectReference Include="..\Source_Data\Source_Data.sqlproj">
    <SuppressMissingDependenciesErrors>False</SuppressMissingDependenciesErrors>
    <DatabaseSqlCmdVariable>Source_Data</DatabaseSqlCmdVariable>
</ProjectReference>
```

Meaning: SupplyChain_Warehouse **depends on** Source_Data. If Source_Data changes a column → SupplyChain build FAILS.

### SqlCmdVariable — multi-environment

```xml
<SqlCmdVariable Include="Source_Data">
    <DefaultValue>Source_Data</DefaultValue>
    <Value>$(SqlCmdVar__1)</Value>
</SqlCmdVariable>
```

In SQL, use `$(Source_Data)` instead of a hardcoded database name:
```sql
SELECT * FROM [$(Source_Data)].schema.table
-- DEV: [Source_Data_DEV].schema.table
-- PROD: [Source_Data_PROD].schema.table
```

### CI Pipeline

```yaml
# azure-pipelines.yml (simplified)
steps:
  - task: UseDotNet@2
    inputs:
      version: '8.0.x'
  - script: dotnet restore **/*.sqlproj
  - script: dotnet build **/*.sqlproj --configuration Release
```

Push code → build 17 projects → fail if any reference is incorrect.

---

## 3 Approaches for v9

### Approach 1: GitHub Actions SQL Lint (lightest)

**Difficulty**: Easy
**Setup time**: 30 minutes
**Errors caught**: Syntax errors, basic SQL issues
**Not caught**: Reference errors (non-existent columns)

```yaml
# .github/workflows/sql-lint.yml
name: SQL Lint
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install sqlfluff
        run: pip install sqlfluff
      - name: Lint SQL files
        run: sqlfluff lint docs/**/*.sql --dialect tsql
```

**Pros**: Quick setup, runs on every PR
**Cons**: Only catches syntax errors, cannot detect whether a column exists

---

### Approach 2: SQL Database Project (recommended)

**Difficulty**: Medium
**Setup time**: 2-3 hours
**Errors caught**: Reference errors within the same Warehouse (non-existent columns, tables, views)
**Not caught**: Cross-database (Lakehouse sources)

#### Step 1: Connect Fabric Git

```
Fabric Portal → SupplyChain_Warehouse → Settings → Git integration
    → Connect to GitHub repo
    → Fabric automatically exports all objects as .sql files
```

Fabric will create the following structure:
```
SupplyChain_Warehouse/
├── SupplyChain_Warehouse.sqlproj     (auto-generated)
├── bronze/
│   ├── Tables/brz_*.sql
│   └── Views/vw_brz_*.sql
├── silver/
│   ├── Tables/slv_*.sql
│   └── Views/vw_slv_*.sql
├── gold/
│   ├── Tables/gld_*.sql
│   └── Views/vw_gld_*.sql
└── meta/
    ├── Tables/*.sql
    ├── StoredProcedures/*.sql
    └── Functions/*.sql
```

#### Step 2: Create GitHub Action build

```yaml
# .github/workflows/build-sqlproj.yml
name: Build SQL Project
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'
      - name: Restore
        run: dotnet restore SupplyChain_Warehouse/*.sqlproj
      - name: Build
        run: dotnet build SupplyChain_Warehouse/*.sqlproj --configuration Release
```

#### Step 3: Test

```bash
# Local test (requires .NET SDK 8)
dotnet build SupplyChain_Warehouse.sqlproj

# Result:
# Build succeeded → all references OK
# Build FAILED → points to the exact line/file with errors
```

**Pros**: Catches reference errors accurately, integrates with Git workflow
**Cons**: Does not validate cross-database (Lakehouse sources)

---

### Approach 3: Full Enterprise (ProjectReference)

**Difficulty**: Harder
**Setup time**: 1 day
**Errors caught**: Everything — including cross-database references

#### Add ProjectReference

```xml
<!-- SupplyChain_Warehouse.sqlproj -->
<ItemGroup>
    <ProjectReference Include="..\Enterprise_Lakehouse\Enterprise_Lakehouse.sqlproj">
        <SuppressMissingDependenciesErrors>False</SuppressMissingDependenciesErrors>
        <DatabaseSqlCmdVariable>Enterprise_Lakehouse</DatabaseSqlCmdVariable>
    </ProjectReference>
</ItemGroup>
```

#### Change 3-part naming to SqlCmdVariable

```sql
-- Before:
SELECT * FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail;

-- After:
SELECT * FROM [$(Enterprise_Lakehouse)].SalesHistory_AFI.InvoiceDetail;
```

#### Create .sqlproj for Lakehouse

You need to create a .sqlproj describing the schema of Enterprise_Lakehouse (only table definitions are needed, not data).

**Pros**: Identical to Enterprise at 100%, catches all errors
**Cons**: Requires maintaining a .sqlproj for Lakehouse, requires changing all VIEWs to `$(...)` syntax

---

## Comparison of 3 Approaches

| | Approach 1: Lint | Approach 2: .sqlproj | Approach 3: Full ProjectRef |
|-|------------|---------------|----------------------|
| **Difficulty** | Easy | Medium | Hard |
| **Setup** | 30 minutes | 2-3 hours | 1 day |
| **Catches syntax** | Yes | Yes | Yes |
| **Catches reference errors** | No | Yes (same DB) | Yes (cross-DB) |
| **Catches cross-DB** | No | No | Yes |
| **Requires Fabric Git** | No | Yes | Yes |
| **When to use** | < 30 tables | 30-100 tables | 100+ tables, multiple teams |

---

## Recommendation

| Scale | Recommended |
|--------|----------|
| **Current (28 tables, 1 team)** | Not needed yet — runtime detection is fast enough |
| **50+ tables** | Approach 2 (.sqlproj) |
| **100+ tables, multiple teams** | Approach 3 (Full ProjectRef) |
| **Integrate with Enterprise CI/CD** | Approach 3 (required) |

When ready, start with **Approach 2**: connect Fabric Git → Fabric automatically exports .sql → create GitHub Action build.
