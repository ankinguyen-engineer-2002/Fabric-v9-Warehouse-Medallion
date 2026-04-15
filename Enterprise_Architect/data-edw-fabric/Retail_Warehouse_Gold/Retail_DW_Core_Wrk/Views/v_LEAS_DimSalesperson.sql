-- Auto Generated (Do not modify) 95B35379E614E079EFFD11B7818B0497DB827DEB33FF1063C882D7A522030736

/*
2025-08-25 || Harshit S:  Created View
2025-08-27 || Satya B: Added salesperson Column
*/

CREATE         VIEW [Retail_DW_Core_Wrk].[v_LEAS_DimSalesperson] AS
SELECT
    SP.[SalesPersonID],
    SP.[SalesPersonKey],
    SP.SalesPersonName as [Name],
    [SalesPersonTypeID],
    SP.[ActiveStatus],
    [ManagerID],
    [HomeStore],
    CONCAT(CONCAT(LM.StoreID, '-'), LM.LocationName) AS Store,
    SP.HireDate,
    JobName,
    PR.Email Email,
    CONCAT(CONCAT(SP.[SalesPersonKey], '-'), SP.[SalesPersonName]) AS Salesperson
FROM [Retail_DW_Core].[DimSalesPerson] SP
    LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[PeopleRecords] PR
        ON SP.PeopleID = PR.PeopleID
    LEFT JOIN [Retail_DW_Core].[DimHRJobs] HJ
        ON PR.JobID = HJ.JobID
    LEFT JOIN [Retail_DW_Core].[DimStoreLocation] LM
        ON SP.HomeStore = LM.StoreID
WHERE SP.ActiveStatus = 1;