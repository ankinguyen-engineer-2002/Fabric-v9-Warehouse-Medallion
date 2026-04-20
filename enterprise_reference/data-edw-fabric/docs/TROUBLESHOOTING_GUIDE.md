# Troubleshooting Guide - Fabric SQL Warehouse Projects

## Build Issues

### Issue: "Cannot find database [$(VariableName)]"

**Error Message:**
```
Error: Cannot find database [$(Source_Data)]
```

**Solution:**

1. Check SqlCmdVariable Definition
```xml
<!-- ❌ WRONG - Empty DefaultValue -->
<SqlCmdVariable Include="Source_Data">
  <Value>$(SqlCmdVar__1)</Value>
  <DefaultValue></DefaultValue>
</SqlCmdVariable>

<!-- ✅ CORRECT -->
<SqlCmdVariable Include="Source_Data">
  <Value>$(SqlCmdVar__1)</Value>
  <DefaultValue>Source_Data</DefaultValue>
</SqlCmdVariable>
```

2. Verify ProjectReference exists
```xml
<ProjectReference Include="..\SourceData\Source_Data\Source_Data.sqlproj">
  <Name>Source_Data</Name>
  <DatabaseSqlCmdVariable>Source_Data</DatabaseSqlCmdVariable>
</ProjectReference>
```

3. Rebuild
```powershell
dotnet clean ProjectName.sqlproj
dotnet build ProjectName.sqlproj -c Release
```

---

### Issue: "Invalid object name [table_name]"

**Error Message:**
```
Error: Invalid object name [$(Source_Data)].[retail_external].[invalidemailaddresses]
```

**Solution:**

1. Check exact table casing in Source_Data
```sql
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'Retail_External'
```

2. Update SQL to match exact casing
```sql
-- ❌ WRONG
FROM [$(Source_Data)].[retail_external].[invalidemailaddresses]

-- ✅ CORRECT
FROM [$(Source_Data)].[Retail_External].[InvalidEmailAddresses]
```

3. Rebuild
```powershell
dotnet build ProjectName.sqlproj -c Release
```

---

### Issue: "project.assets.json" Error

**Error Message:**
```
Error: The project assets file is invalid or missing
```

**Solution:**

1. Add BeforeBuild Target
```xml
<Target Name="BeforeBuild">
  <Delete Files="$(BaseIntermediateOutputPath)\project.assets.json" />
</Target>
```

2. Clean and rebuild
```powershell
dotnet clean ProjectName.sqlproj
dotnet build ProjectName.sqlproj -c Release
```

---

### Issue: Circular Dependency Error

**Error Message:**
```
Error: Circular dependency detected between projects
```

**Solution:**

1. Identify circular reference
```powershell
Select-String -Path "ProjectA\ProjectA.sqlproj" -Pattern "ProjectReference"
Select-String -Path "ProjectB\ProjectB.sqlproj" -Pattern "ProjectReference"
```

2. Remove unnecessary reference from one project

3. Verify dependency chain
```
Source_Data (Bronze)
    ↓
Retail_Warehouse (Silver)
    ↓
Retail_Warehouse_Gold (Gold)
```

---

## Deployment Issues

### Issue: "Incompatible Platform"

**Error Message:**
```
Error: The target platform is incompatible with this project
```

**Solution:**

1. Check DSP Setting
```xml
<!-- ❌ WRONG -->
<DSP>Microsoft.Data.Tools.Schema.Sql.SqlServerDatabaseSchemaProvider</DSP>

<!-- ✅ CORRECT for Fabric -->
<DSP>Microsoft.Data.Tools.Schema.Sql.SqlDwUnifiedDatabaseSchemaProvider</DSP>
```

2. Update .sqlproj and rebuild

---

### Issue: "Unsupported Feature"

**Error Message:**
```
Error: Feature 'FILEGROUP' is not supported in this edition
```

**Solution:**

1. Find unsupported features
```powershell
Get-ChildItem -Recurse -Filter "*.sql" | 
  Select-String -Pattern "FILEGROUP|PARTITION|FULLTEXT"
```

2. Remove or replace unsupported features

| Unsupported | Action |
|------------|--------|
| FILEGROUP | Remove |
| PARTITION SCHEME | Use table design |
| FULL-TEXT INDEX | Use standard indexes |

---

## SQL Development Issues

### Issue: View References Wrong Database

**Error Message:**
```
Error: Invalid object name [$(WrongDatabase)].[schema].[table]
```

**Solution:**

1. Check view definition
```sql
-- ❌ WRONG
CREATE VIEW [dbo].[v_CustomerData] AS
SELECT * FROM [$(Databricks)].[Retail_Corporate].[Customers]

-- ✅ CORRECT
CREATE VIEW [dbo].[v_CustomerData] AS
SELECT * FROM [$(Source_Data)].[Retail_Corporate].[Customers]
```

2. Update and rebuild

---

### Issue: Stored Procedure References Missing Table

**Error Message:**
```
Error: Invalid object name [table_name]
```

**Solution:**

1. Check procedure definition
```sql
-- ❌ WRONG - Missing schema
INSERT INTO DimCustomer SELECT * FROM [$(Source_Data)].[Retail_Corporate].[Customers]

-- ✅ CORRECT - Include schema
INSERT INTO [dbo].[DimCustomer] 
SELECT * FROM [$(Source_Data)].[Retail_Corporate].[Customers]
```

---

## Performance Issues

### Slow Queries

**Solutions:**

1. Add Clustered Columnstore Index
```sql
CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSales
ON [Retail_Sales].[FactSales]
```

2. Create Statistics
```sql
CREATE STATISTICS stat_CustomerID 
ON [dbo].[DimCustomer](CustomerID)
```

3. Check data types (avoid NVARCHAR(MAX), use INT instead of BIGINT)

---

## Configuration Issues

### Inconsistent SqlCmdVariable Naming

**Problem:** Different projects use different variable names

**Solution:** Standardize across all projects
```xml
<SqlCmdVariable Include="Source_Data">
  <DefaultValue>Source_Data</DefaultValue>
</SqlCmdVariable>

<SqlCmdVariable Include="ETL_Framework">
  <DefaultValue>ETL_Framework</DefaultValue>
</SqlCmdVariable>
```

---

## Validation Checklist

Before reporting an issue:

- [ ] Ran `dotnet clean` and `dotnet build`
- [ ] Verified all SqlCmdVariables have DefaultValues
- [ ] Checked variable names match database names
- [ ] Verified ProjectReferences exist
- [ ] Confirmed DSP is SqlDwUnifiedDatabaseSchemaProvider
- [ ] Checked for unsupported Fabric features
- [ ] Verified SQL uses [$(VariableName)] syntax
- [ ] Confirmed collation is 1033, CI
- [ ] Checked for circular dependencies

---

**Last Updated**: October 21, 2025  
**Version**: 1.0

