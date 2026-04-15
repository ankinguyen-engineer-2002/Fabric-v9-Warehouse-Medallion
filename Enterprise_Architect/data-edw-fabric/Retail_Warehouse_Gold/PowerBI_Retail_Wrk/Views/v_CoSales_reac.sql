CREATE VIEW [PowerBI_Retail_Wrk].[v_CoSales_reac]
AS
WITH CoSalesDWData AS (
    SELECT  SalesOrder AS OrderId,
            CASE 
            WHEN LocationID IS NULL THEN NULL
            WHEN LTRIM(RTRIM(LocationID)) LIKE '[A-Z]%' THEN LTRIM(RTRIM(LocationID)) 
            ELSE RIGHT('000' + LTRIM(RTRIM(CAST(TRY_CAST(LocationID AS INT) AS VARCHAR(50)))), 3)
            END AS CoSales_LocationId,
            IssueLoggedDate,
            LastUpdatedBy AS Agent,
            DirectorManager,
            DistrictManager,
            SUM(AmountAtRisk) AS AmountAtRisk,
            CASE WHEN IssueStatus = 'Saved' THEN SUM(AmountatRisk) ELSE 0 END AS SavedAmount,
            CASE WHEN IssueStatus = 'Cancelled' THEN SUM(AmountatRisk) ELSE 0 END AS CancelledAmount
    FROM [PowerBI_Retail_Wrk].[v_CoSales_VIPCustlog]
    GROUP BY SalesOrder,
             LocationID,
             IssueLoggedDate,
             LastUpdatedBy,
             DirectorManager,
             DistrictManager,
             IssueStatus
),
SalesTransData AS (
    SELECT  OrderID,
            CASE 
            WHEN l.StoreID IS NULL THEN NULL
            WHEN l.StoreID < 100 THEN RIGHT('000' + CAST(l.StoreID AS VARCHAR(50)), 3)
            ELSE CAST(l.StoreID AS VARCHAR(50))
            END AS LocationId,
            CONVERT(DATE, CAST(TransDateKey AS VARCHAR(8)), 112) AS TransDate,
            sp.SalesPersonID,
            SUM(Sales * p.PrimaryCategory) AS WrittenSales,
            SUM(Sales * GrossMultiplier) AS GrossWrittenSales,
            SUM(Sales * p.PrimaryCategory * GrossMultiplier) AS GrossWrittenPulseSales
    FROM [Retail_DW_Core].[FactSales] s
    LEFT JOIN [Retail_DW_Core].[DimProduct] p ON s.ProductKey = p.ProductKey
    LEFT JOIN [Retail_DW_Core].[DimSalesPerson] sp ON s.SalesPersonKey = sp.SalesPersonKey
    LEFT JOIN [Retail_DW_Core].[DimStoreLocation] l ON l.LocationKey = s.LocationKey
    WHERE TransDateKey >= CONVERT(INT, FORMAT(DATEFROMPARTS(YEAR(GETDATE())-1, 01, 01), 'yyyyMMdd'))
      AND TransDateKey < CONVERT(INT, FORMAT(GETDATE(), 'yyyyMMdd'))
      AND SalesType = 'W'
    GROUP BY OrderID,
            l.StoreID,
            TransDateKey,
            sp.SalesPersonID
),
ManagersList AS (
    SELECT CAST(Store AS VARCHAR(50)) AS Store,
           DirectorManager,
           DistrictManager
    FROM [PowerBI_Retail_Wrk].[v_CoSales_StoreManagers]
),
OrdersandSalespeople AS (
    SELECT DISTINCT SourceOrderID as OrderID, SalesPersonID
    FROM [Retail_DW_Core].[FactSalesOrderHeader]
    WHERE OrderDate >= DATEFROMPARTS(YEAR(GETDATE())-1,01,01)
      AND OrderDate < GETDATE()
)
-- Results
SELECT  CS.OrderId,
        CS.CoSales_LocationId AS LocationID,
        CS.IssueLoggedDate AS TransDate,
        CS.DirectorManager,
        CS.DistrictManager,
        OS.SalesPersonID,
        'CoSales' AS Category,
        0 AS WrittenSales,
        0 AS GrossWrittenSales,
        0 AS GrossWrittenPulseSales,
        SUM(CS.AmountAtRisk) AS AmountAtRisk,
        SUM(CS.SavedAmount) AS SavedAmount,
        SUM(CS.CancelledAmount) AS CancelledAmount
FROM CoSalesDWData CS
    LEFT JOIN OrdersandSalespeople OS
        ON CS.OrderId = OS.OrderID
WHERE CS.OrderId IS NOT NULL
GROUP BY CS.OrderId,
        CS.CoSales_LocationId,
        CS.IssueLoggedDate,
        CS.DirectorManager,
        CS.DistrictManager,
        OS.SalesPersonID

UNION ALL

SELECT  ST.OrderID,
        ST.LocationID,
        ST.TransDate,
        ML.DirectorManager AS DirectorManager,
        ML.DistrictManager AS DistrictManager,
        ST.SalesPersonID,
        'SalesDetailTrans' AS Category,
        SUM(ST.WrittenSales) AS WrittenSales,
        SUM(ST.GrossWrittenSales) AS GrossWrittenSales,
        SUM(ST.GrossWrittenPulseSales) AS GrossWrittenPulseSales,
        0 AS AmountAtRisk,
        0 AS SavedAmount,
        0 AS CancelledAmount
FROM SalesTransData ST
LEFT JOIN ManagersList ML
    ON ST.LocationID = ML.Store
GROUP BY ST.OrderID,
        ST.LocationID,
        ST.TransDate,
        ML.DirectorManager,
        ML.DistrictManager,
        ST.SalesPersonID