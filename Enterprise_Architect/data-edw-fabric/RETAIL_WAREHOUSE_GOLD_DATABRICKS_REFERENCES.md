# Retail_Warehouse_Gold - Databricks References

## Summary
The **Retail_Warehouse_Gold** project references **2 Databricks schemas** with a total of **6 tables/views**.

All references are through the `[$(Databricks)]` SQL variable.

---

## Databricks Objects Referenced

### 1. **masterdata_hr_ukg_dsg** Schema (5 tables)

| Table Name | Used In | Purpose |
|------------|---------|---------|
| **peoplerecords** | 6 views | Employee/people master data (PeopleID, EmployeeNumber, etc.) |
| **hremployeehistory** | 9 views | Employee history records (TransDate, EmployeeNumber, etc.) |
| **hrjobs_dsg** | 1 view | HR job information |
| **peopletimesheet** | 1 view | Employee timesheet data |

### 2. **retail_external** Schema (1 table)

| Table Name | Used In | Purpose |
|------------|---------|---------|
| **hrjobs** | 1 view | HR job reference data |

---

## Files Using Databricks References

### HR/Employee Data Views (12 files)

1. **v_APPS_DimSalesperson.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[peoplerecords]`

2. **v_DimHREmployeeHistory.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]` (2 references)

3. **v_DimHRJobs.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hrjobs_dsg]`

4. **v_LEAS_DimSalesperson.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[peoplerecords]`

5. **v_SMQQ_FactEmployeeHistory.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]` (2 references)

6. **v_SMQQ_FactRSADetails.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]` (2 references)
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[peoplerecords]`

7. **v_SMQQ_FactRSAHours.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]`

8. **v_STGQ_FactEmployeeHistory.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]` (2 references)
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[peoplerecords]`

9. **v_STGQ_FactEmployeeHours.sql**
   - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]` (2 references)

10. **v_STGQ_FactTimeSheetDataCheck.sql**
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]`
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[peoplerecords]`

11. **v_STGQ_FactTimesheets.sql**
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[peopletimesheet]`
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[peoplerecords]`
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]`

12. **v_STGQ_FactTraffic.sql**
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]` (2 references)

13. **v_STGQ_FactTrafficBudget.sql**
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]`

14. **v_STGQ_FactTrafficBudgetLocations.sql**
    - `[$(Databricks)].[masterdata_hr_ukg_dsg].[hremployeehistory]`
    - `[$(Databricks)].[retail_external].[hrjobs]`

---

## Key Observations

- **All references are READ-ONLY** - Used in view definitions for data integration
- **HR/Employee data is critical** - 12 views depend on Databricks HR tables
- **No schema case issues** - All references use correct casing: `masterdata_hr_ukg_dsg`, `retail_external`
- **No table case issues** - All table names use correct casing
- **Consolidation opportunity** - Could potentially consolidate HR data into Source_Data project

---

## Impact Analysis

**Cannot be removed without breaking:**
- 14 views in Retail_Warehouse_Gold
- Dependent reports and dashboards using these views
- HR/Employee dimension tables
- Timesheet and traffic fact tables

