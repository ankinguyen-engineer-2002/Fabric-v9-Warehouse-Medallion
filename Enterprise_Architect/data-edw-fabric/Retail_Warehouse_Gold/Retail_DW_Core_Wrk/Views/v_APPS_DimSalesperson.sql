-- Auto Generated (Do not modify) 77AE26FA2216BE0EB6D5D59A17D8242151464604CB38D91D4165E159F319D0A9

/*
2025-08-21 || Satya B:  Created View
*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_APPS_DimSalesperson] AS

SELECT 
    SP.[SalesPersonID], 
    SP.SalesPersonName AS Name,
    SP.[SalesPersonTypeID], 
    SP.[ActiveStatus], 
    SP.[ManagerID], 
    SP.[HomeStore], 
    PR.[HireDate], 
    HJ.[JobName] 
FROM [Retail_DW_Core].[DimSalesPerson] SP
LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[PeopleRecords] PR ON SP.[PeopleID] = PR.[PeopleID] 
LEFT JOIN [Retail_DW_Core].[DimHRJobs] HJ ON PR.[JobID] = HJ.[JobID] 
WHERE SP.[SalesPersonID] <> 'AE13'