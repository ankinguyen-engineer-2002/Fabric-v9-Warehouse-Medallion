# Developer Best Practices Guide - Fabric SQL Warehouse Projects

## 1. Project Structure

### Folder Organization
```
ProjectName/
├── ProjectName.sqlproj
├── dbo/
│   ├── Tables/
│   ├── Views/
│   ├── Stored Procedures/
│   └── Functions/
├── Retail_External/
│   ├── Tables/
│   └── Views/
├── Retail_Corporate/
│   ├── Tables/
│   └── Views/
├── Retail_Sales_Wrk/          (Working schema)
│   └── Stored Procedures/
├── Retail_Sales_Enh/          (Enhancement schema)
│   └── Views/
└── Publish/
    ├── ProjectName_Dev.publish.xml
    └── ProjectName_Prod.publish.xml
```

---

## 2. Configuration Standards

### .sqlproj PropertyGroup
```xml
<PropertyGroup>
  <Name>ProjectName</Name>
  <ProjectGuid>{UNIQUE-GUID}</ProjectGuid>
  <DSP>Microsoft.Data.Tools.Schema.Sql.SqlDwUnifiedDatabaseSchemaProvider</DSP>
  <ModelCollation>1033, CI</ModelCollation>
  <TargetDatabaseSet>True</TargetDatabaseSet>
</PropertyGroup>
```

### SqlCmdVariable Configuration
```xml
<SqlCmdVariable Include="Source_Data">
  <Value>$(SqlCmdVar__1)</Value>
  <DefaultValue>Source_Data</DefaultValue>
</SqlCmdVariable>

<SqlCmdVariable Include="ETL_Framework">
  <Value>$(SqlCmdVar__2)</Value>
  <DefaultValue>ETL_Framework</DefaultValue>
</SqlCmdVariable>
```

### ProjectReference Configuration
```xml
<ProjectReference Include="..\SourceData\Source_Data\Source_Data.sqlproj">
  <Name>Source_Data</Name>
  <DatabaseSqlCmdVariable>Source_Data</DatabaseSqlCmdVariable>
</ProjectReference>
```

---

## 3. Naming Conventions

| Object Type | Prefix | Example | Notes |
|------------|--------|---------|-------|
| Table | None | DimCustomer | PascalCase |
| View | v_ | v_CustomerSummary | PascalCase after prefix |
| Stored Procedure | usp_ | usp_Refresh_DimCustomer | PascalCase after prefix |
| Function | fn_ | fn_GetCustomerAge | PascalCase after prefix |
| Working Schema | _Wrk | Retail_Sales_Wrk | Suffix for temporary objects |
| Enhancement Schema | _Enh | Retail_Sales_Enh | Suffix for enhanced objects |

---

## 4. Cross-Database References

### Correct Syntax
```sql
-- Reference another database using SqlCmdVariable
SELECT *
FROM [$(Source_Data)].[Retail_External].[InvalidEmailAddresses]

-- Multiple database references
SELECT 
    c.CustomerID,
    s.SalesAmount
FROM [$(Source_Data)].[Retail_Corporate].[Customers] c
INNER JOIN [$(Retail_Warehouse)].[Retail_Sales].[FactSales] s
    ON c.CustomerID = s.CustomerID
```

### Common Mistakes
```sql
-- ❌ WRONG - Missing brackets
FROM $(Source_Data).Retail_External.InvalidEmailAddresses

-- ❌ WRONG - Wrong case
FROM [$(source_data)].[retail_external].[invalidemailaddresses]

-- ❌ WRONG - Missing variable
FROM [Source_Data].[Retail_External].[InvalidEmailAddresses]
```

---

## 5. SQL Development Best Practices

### Table Design
- Use appropriate data types (INT, DECIMAL(10,2), NVARCHAR(100))
- Avoid NVARCHAR(MAX) and BIGINT for small numbers
- Include NOT NULL constraints where appropriate
- Use clustered columnstore indexes for large tables

### View Creation
```sql
CREATE VIEW [dbo].[v_CustomerData] AS
SELECT 
    CustomerID,
    CustomerName,
    Email
FROM [$(Source_Data)].[Retail_Corporate].[Customers]
WHERE IsActive = 1
```

### Stored Procedure Pattern
```sql
CREATE PROCEDURE [dbo].[usp_Refresh_DimCustomer]
AS
BEGIN
    TRUNCATE TABLE [dbo].[DimCustomer]
    
    INSERT INTO [dbo].[DimCustomer]
    SELECT * FROM [$(Source_Data)].[Retail_Corporate].[Customers]
END
```

---

## 6. Build & Deployment

### Local Build Commands
```powershell
# Build a project
cd ProjectName
dotnet build ProjectName.sqlproj -c Release

# Clean build
dotnet clean ProjectName.sqlproj
dotnet build ProjectName.sqlproj -c Release

# Check for errors
dotnet build ProjectName.sqlproj -c Release 2>&1 | Select-String "Error|Warning"
```

### Deployment Steps
1. Verify build succeeds locally
2. Run pre-commit checklist
3. Commit changes with descriptive message
4. Push to feature branch
5. Create pull request
6. Deploy to development environment
7. Test thoroughly
8. Deploy to production

---

## 7. Common Issues & Solutions

### Issue: "Cannot find database [$(VariableName)]"
**Solution**: Verify SqlCmdVariable DefaultValue matches database name exactly

### Issue: "Invalid object name [table_name]"
**Solution**: Check table casing matches Source_Data definition

### Issue: Build fails with "project.assets.json" error
**Solution**: Add BeforeBuild target to delete file before build

### Issue: Circular dependency error
**Solution**: Review ProjectReferences and remove unnecessary ones

---

## 8. Pre-Commit Checklist

- [ ] Code builds successfully locally
- [ ] All SqlCmdVariables have DefaultValues
- [ ] Variable names match database names
- [ ] ProjectReferences exist for all dependencies
- [ ] DSP is SqlDwUnifiedDatabaseSchemaProvider
- [ ] Collation is 1033, CI
- [ ] No unsupported Fabric features used
- [ ] Naming conventions followed
- [ ] SQL uses [$(VariableName)] syntax
- [ ] No circular dependencies
- [ ] Commit message is descriptive

---

**Last Updated**: October 21, 2025  
**Version**: 1.0

