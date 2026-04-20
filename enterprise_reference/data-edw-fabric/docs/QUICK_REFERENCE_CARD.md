# Quick Reference Card - Fabric SQL Warehouse

## Quick Start Commands

```powershell
# Build a project
cd ProjectName
dotnet build ProjectName.sqlproj -c Release

# Clean build
dotnet clean ProjectName.sqlproj
dotnet build ProjectName.sqlproj -c Release

# Check for errors
dotnet build ProjectName.sqlproj -c Release 2>&1 | Select-String "Error|Warning"

# Find all SqlCmdVariables
Select-String -Path "*.sqlproj" -Pattern "SqlCmdVariable"

# Find cross-database references
Get-ChildItem -Recurse -Filter "*.sql" | Select-String -Pattern "\$\("

# Check for unsupported features
Get-ChildItem -Recurse -Filter "*.sql" | Select-String -Pattern "FILEGROUP|PARTITION|FULLTEXT"
```

---

## .sqlproj Template

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath)\Microsoft.Build.Sql\v0\Microsoft.Build.Sql.props" />
  
  <PropertyGroup>
    <Name>ProjectName</Name>
    <ProjectGuid>{UNIQUE-GUID}</ProjectGuid>
    <DSP>Microsoft.Data.Tools.Schema.Sql.SqlDwUnifiedDatabaseSchemaProvider</DSP>
    <ModelCollation>1033, CI</ModelCollation>
    <TargetDatabaseSet>True</TargetDatabaseSet>
  </PropertyGroup>

  <ItemGroup>
    <SqlCmdVariable Include="Source_Data">
      <Value>$(SqlCmdVar__1)</Value>
      <DefaultValue>Source_Data</DefaultValue>
    </SqlCmdVariable>
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\SourceData\Source_Data\Source_Data.sqlproj">
      <Name>Source_Data</Name>
      <DatabaseSqlCmdVariable>Source_Data</DatabaseSqlCmdVariable>
    </ProjectReference>
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.SqlServer.Dacpacs.Master">
      <Version>160.0.0</Version>
      <GeneratePathProperty>True</GeneratePathProperty>
      <DatabaseVariableLiteralValue>master</DatabaseVariableLiteralValue>
    </PackageReference>
  </ItemGroup>

  <Target Name="BeforeBuild">
    <Delete Files="$(BaseIntermediateOutputPath)\project.assets.json" />
  </Target>

  <Import Project="$(MSBuildExtensionsPath)\Microsoft.Build.Sql\v0\Microsoft.Build.Sql.targets" />
</Project>
```

---

## Naming Conventions

| Object Type | Prefix | Example | Pattern |
|------------|--------|---------|---------|
| Table | None | DimCustomer | PascalCase |
| View | v_ | v_CustomerSummary | v_PascalCase |
| Stored Procedure | usp_ | usp_Refresh_DimCustomer | usp_PascalCase |
| Function | fn_ | fn_GetCustomerAge | fn_PascalCase |
| Working Schema | _Wrk | Retail_Sales_Wrk | Schema_Wrk |
| Enhancement Schema | _Enh | Retail_Sales_Enh | Schema_Enh |

---

## Cross-Database Reference Pattern

```sql
-- Correct syntax
SELECT *
FROM [$(Source_Data)].[Retail_External].[InvalidEmailAddresses]

-- Multiple references
SELECT 
    c.CustomerID,
    s.SalesAmount
FROM [$(Source_Data)].[Retail_Corporate].[Customers] c
INNER JOIN [$(Retail_Warehouse)].[Retail_Sales].[FactSales] s
    ON c.CustomerID = s.CustomerID
```

---

## Pre-Commit Checklist

- [ ] Build succeeds: `dotnet build ProjectName.sqlproj -c Release`
- [ ] SqlCmdVariables have DefaultValues
- [ ] Variable names match database names
- [ ] ProjectReferences exist for dependencies
- [ ] DSP is SqlDwUnifiedDatabaseSchemaProvider
- [ ] Collation is 1033, CI
- [ ] No unsupported Fabric features
- [ ] Naming conventions followed
- [ ] SQL uses [$(VariableName)] syntax
- [ ] No circular dependencies

---

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| Cannot find database | Missing DefaultValue | Add DefaultValue to SqlCmdVariable |
| Invalid object name | Wrong table casing | Match exact casing from Source_Data |
| project.assets.json error | NuGet cache issue | Add BeforeBuild target |
| Circular dependency | Projects reference each other | Remove unnecessary reference |
| Unsupported feature | Using Fabric-incompatible feature | Remove FILEGROUP, PARTITION, etc. |

---

## Data Architecture Layers

```
Gold Layer (Business-Ready)
├── Retail_Warehouse_Gold
└── Optimized for reporting

Silver Layer (Cleaned & Standardized)
├── Retail_Warehouse
├── Finance_Warehouse
└── Business logic applied

Bronze Layer (Raw Data)
├── Source_Data
└── Minimal transformation
```

---

## Fabric SQL Warehouse Features

### ✅ Supported
- Tables (heap, clustered columnstore)
- Views
- Stored Procedures
- Functions
- Schemas
- Indexes
- Statistics

### ❌ Unsupported
- Filegroups
- Partitioning schemes
- Full-text search
- Replication
- Service Broker
- Temporal tables

---

**Last Updated**: October 21, 2025  
**Version**: 1.0

