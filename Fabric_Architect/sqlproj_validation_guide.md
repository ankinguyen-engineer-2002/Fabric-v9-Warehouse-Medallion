# .sqlproj Validation Guide
> Build-time SQL validation: bat loi truoc khi deploy, khong doi runtime moi biet
> 3 phuong an: tu nhe den full Enterprise

---

## Van de hien tai

v9 **khong co build-time validation**. Loi chi phat hien khi pipeline chay:

```
Developer sua VIEW → push Git → deploy
    ↓
Pipeline trigger → SP chay CTAS tu VIEW
    ↓
RUNTIME ERROR: "Invalid column name 'xyz'"
    ↓
Table fail → phat hien loi (muon)
```

Enterprise team (US) co .sqlproj validation — loi phat hien **truoc khi deploy**:

```
Developer sua VIEW → push Git → Azure Pipeline build
    ↓
DacFx doc tat ca .sql files → validate references
    ↓
BUILD FAIL: "unresolved reference to [xyz]"
    ↓
Khong deploy → developer fix truoc (som)
```

---

## Enterprise dang lam the nao

### Cau truc

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
├── ... (17 .sqlproj tong cong)
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

Nghia la: SupplyChain_Warehouse **phu thuoc** Source_Data. Neu Source_Data doi cot → SupplyChain build FAIL.

### SqlCmdVariable — multi-environment

```xml
<SqlCmdVariable Include="Source_Data">
    <DefaultValue>Source_Data</DefaultValue>
    <Value>$(SqlCmdVar__1)</Value>
</SqlCmdVariable>
```

Trong SQL dung `$(Source_Data)` thay vi ten database cung:
```sql
SELECT * FROM [$(Source_Data)].schema.table
-- DEV: [Source_Data_DEV].schema.table
-- PROD: [Source_Data_PROD].schema.table
```

### CI Pipeline

```yaml
# azure-pipelines.yml (don gian hoa)
steps:
  - task: UseDotNet@2
    inputs:
      version: '8.0.x'
  - script: dotnet restore **/*.sqlproj
  - script: dotnet build **/*.sqlproj --configuration Release
```

Push code → build 17 projects → fail neu bat ky reference nao sai.

---

## 3 Phuong an cho v9

### Phuong an 1: GitHub Actions SQL Lint (nhe nhat)

**Do kho**: De
**Thoi gian setup**: 30 phut
**Bat duoc loi gi**: Syntax errors, basic SQL issues
**Khong bat duoc**: Reference errors (column khong ton tai)

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
        run: sqlfluff lint Fabric_Architect/**/*.sql --dialect tsql
```

**Uu diem**: Setup nhanh, chay moi PR
**Nhuoc diem**: Chi bat syntax, khong biet column co ton tai khong

---

### Phuong an 2: SQL Database Project (recommend)

**Do kho**: Trung binh
**Thoi gian setup**: 2-3 gio
**Bat duoc loi gi**: Reference errors trong cung Warehouse (column, table, view khong ton tai)
**Khong bat duoc**: Cross-database (source Lakehouse)

#### Buoc 1: Ket noi Fabric Git

```
Fabric Portal → SupplyChain_Warehouse → Settings → Git integration
    → Connect to GitHub repo
    → Fabric tu dong export tat ca objects ra .sql files
```

Fabric se tao cau truc:
```
SupplyChain_Warehouse/
├── SupplyChain_Warehouse.sqlproj     (tu dong tao)
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

#### Buoc 2: Tao GitHub Action build

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

#### Buoc 3: Test

```bash
# Local test (can .NET SDK 8)
dotnet build SupplyChain_Warehouse.sqlproj

# Ket qua:
# Build succeeded → tat ca references OK
# Build FAILED → chi ra dong/file bi loi
```

**Uu diem**: Bat loi reference chinh xac, tich hop Git workflow
**Nhuoc diem**: Khong validate cross-database (Lakehouse sources)

---

### Phuong an 3: Full Enterprise (ProjectReference)

**Do kho**: Kho hon
**Thoi gian setup**: 1 ngay
**Bat duoc loi gi**: Tat ca — bao gom cross-database references

#### Them ProjectReference

```xml
<!-- SupplyChain_Warehouse.sqlproj -->
<ItemGroup>
    <ProjectReference Include="..\Enterprise_Lakehouse\Enterprise_Lakehouse.sqlproj">
        <SuppressMissingDependenciesErrors>False</SuppressMissingDependenciesErrors>
        <DatabaseSqlCmdVariable>Enterprise_Lakehouse</DatabaseSqlCmdVariable>
    </ProjectReference>
</ItemGroup>
```

#### Doi 3-part naming sang SqlCmdVariable

```sql
-- Truoc:
SELECT * FROM Enterprise_Lakehouse.SalesHistory_AFI.InvoiceDetail;

-- Sau:
SELECT * FROM [$(Enterprise_Lakehouse)].SalesHistory_AFI.InvoiceDetail;
```

#### Tao .sqlproj cho Lakehouse

Can tao 1 .sqlproj mo ta schema cua Enterprise_Lakehouse (chi can table definitions, khong can data).

**Uu diem**: Giong Enterprise 100%, bat moi loi
**Nhuoc diem**: Can maintain .sqlproj cho Lakehouse, doi tat ca VIEW sang `$(...)` syntax

---

## So sanh 3 phuong an

| | PA 1: Lint | PA 2: .sqlproj | PA 3: Full ProjectRef |
|-|------------|---------------|----------------------|
| **Do kho** | De | Trung binh | Kho |
| **Setup** | 30 phut | 2-3 gio | 1 ngay |
| **Bat syntax** | Co | Co | Co |
| **Bat reference loi** | Khong | Co (cung DB) | Co (cross-DB) |
| **Bat cross-DB** | Khong | Khong | Co |
| **Can Fabric Git** | Khong | Co | Co |
| **Khi nao nen dung** | < 30 tables | 30-100 tables | 100+ tables, nhieu team |

---

## Recommend

| Quy mo | Nen dung |
|--------|----------|
| **Hien tai (28 tables, 1 team)** | Chua can — runtime detection du nhanh |
| **50+ tables** | Phuong an 2 (.sqlproj) |
| **100+ tables, nhieu team** | Phuong an 3 (Full ProjectRef) |
| **Tich hop Enterprise CI/CD** | Phuong an 3 (bat buoc) |

Khi san sang, bat dau tu **Phuong an 2**: ket noi Fabric Git → Fabric tu dong export .sql → tao GitHub Action build.
