CREATE VIEW [AFISales_DW_Wrk].[vFactMarketCommitments]
  AS 


SELECT
         ROW_NUMBER() OVER (ORDER BY RepID)      AS RowID,
        t2.RepID AS [MarketingSpecialist]  ,
        t2.ItemSKU as [Item SKU]    ,
        t2.[Item Key]  ,
        t2.CustomerNumber ,
        t2.ShiptoNumber ,
        t2.SalesTerritoryID ,
        t2.[Committed]   ,
        t2.[Committed - NonHomestore] ,
        t2.[Committed - Homestore] ,
        t2.[Actual Placements] ,
        t2.[Original Commitment]  ,
        t2.[Original Commitment - NonHomestore],
        t2.[Original Commitment - Homestore] ,
        (CASE
             WHEN (t2.[Committed]) <> 0
                  AND (t2.[Committed]) <= t2.[Actual Placements]
                 THEN
                 0
             WHEN (t2.[Committed]) <> 0
                 THEN
        (t2.[Committed]) - t2.[Actual Placements]
             ELSE
                 0
         END
        ) AS [Remaining Goal],
        DimSalesTerritories.[AFI Sales RepID],
        DimSalesTerritories.[AFI Sales Category],
        DimSalesTerritories.[AFI Sales Region Code],
        DimSalesTerritories.RegionCode_RepID_Category,
        t2.[MonthlyQuantity]   
FROM
        (
            SELECT
                t1.RepID,
                t1.ItemSKU,
                'ASHLEY_' + t1.ItemSKU                       AS [Item Key],
                t1.[CustomerNumber],
                t1.[ShiptoNumber],
                t1.[SalesTerritoryID],
                SUM(t1.[Committed])                          AS [Committed],
                SUM(t1.[Committed - NonHomestore])           AS [Committed - NonHomestore],
                SUM(t1.[Committed - Homestore])              AS [Committed - Homestore],
                SUM(t1.[Actual Placements])                  AS [Actual Placements],
                SUM(t1.[Original Commitment])                AS [Original Commitment],
                SUM(t1.[Original Commitment - NonHomestore]) AS [Original Commitment - NonHomestore],
                SUM(t1.[Original Commitment - Homestore])    AS [Original Commitment - Homestore],
                t1.[MonthlyQuantity]                        
            FROM
                (
                    SELECT
                            MarketCommitmentsSum.RepID,
                            MarketCommitmentsSum.ItemSKU                                           AS ItemSKU,
                            MarketCommitmentsSum.CustomerNumber                                    AS [CustomerNumber],
                            MarketCommitmentsSum.ShiptoNumber                                      AS [ShiptoNumber],
                            COALESCE(T1.[SalesTerritoryID], t2.[SalesTerritoryID])                     AS [SalesTerritoryID],
                            MarketCommitmentsSum.Committed + MarketCommitmentsSum.HomestoreCommitted   AS [Committed],
                            MarketCommitmentsSum.Committed                                           AS [Committed - NonHomestore],
                            MarketCommitmentsSum.HomestoreCommitted                                  AS [Committed - Homestore],
                            0                                                                         AS [Actual Placements],
                            MarketCommitmentsSum.OriginalCommitment + MarketCommitmentsSum.HomestoreOriginalCommitment AS [Original Commitment],
                            MarketCommitmentsSum.OriginalCommitment                                  AS [Original Commitment - NonHomestore],
                            MarketCommitmentsSum.HomestoreOriginalCommitment                         AS [Original Commitment - Homestore],
                            MarketCommitmentsSum.NonHomestoreQty                                     AS [MonthlyQuantity]
                    FROM
                            [$(Wholesale_Warehouse)].Marketing.MarketCommitmentsSum
                        LEFT JOIN
                            AFISales_DW.DimItemMaster    
                                ON MarketCommitmentsSum.ItemSKU = DimItemMaster.ItemSKU
                        LEFT JOIN
                            AFISales_DW.DimSalesTerritories T1
                                ON T1.[AFI Sales Region Code] = ISNULL(MarketCommitmentsSum.Region, CAST('Z' AS CHAR(3)))
                                   AND T1.[AFI Sales RepID] = ISNULL(MarketCommitmentsSum.RepID, CAST('ZZZZZ' AS CHAR(5)))
                                   AND T1.[AFI Sales Category] = ISNULL(DimItemMaster.AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
                                   AND T1.[Active Record] = 1
                        LEFT JOIN
                            AFISales_DW.DimSalesTerritories t2
                                ON t2.[AFI Sales Region Code] = CAST('Z' AS CHAR(3))
                                   AND t2.[AFI Sales RepID] = CAST('ZZZZZ' AS CHAR(5))
                                   AND t2.[AFI Sales Category] = ISNULL(DimItemMaster.AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
                                   AND t2.[Active Record] = 1
                    UNION ALL
                    SELECT
                            NULL                                                   AS [MarketCommitmentsSum.RepID],
                            CustItemMonthlyPlacements.ItemSKU                      AS ItemSKU,
                            CustItemMonthlyPlacements.CustomerNumber                AS [CustomerNumber],
                            CustItemMonthlyPlacements.ShiptoNumber                 AS [ShiptoNumber],
                            COALESCE(T1.[SalesTerritoryID], T2.[SalesTerritoryID]) AS [SalesTerritoryID],
                            0                                                      AS [Committed],
                            0                                                      AS [Committed - NonHomestore],
                            0                                                      AS [Committed - Homestore],
                            SUM(   CASE
                                       WHEN  FiscalMonths.[Fiscal Month Indicator] = -1   -- previous month
                                           THEN
                                           CustItemMonthlyPlacements.Placement
                                       ELSE
                                           CustItemMonthlyPlacements.Gained
                                   END
                               )                                                   AS [Actual Placements],
                            0                                                      AS [Original Commitment],
                            0                                                      AS [Original Commitment - NonHomestore],
                            0                                                      AS [Original Commitment - Homestore],
                            0                                                      AS [MonthlyQuantity]
                    FROM
                            AFISales_Enh.CustItemMonthlyPlacements     
                        LEFT JOIN
                            AFISales_DW.DimItemMaster                
                                ON CustItemMonthlyPlacements.ItemSKU = DimItemMaster.ItemSKU
                        LEFT JOIN 
                            (
                                SELECT DISTINCT [FiscalYearPeriod], [Fiscal Month Indicator] 
                                 FROM AFISales_DW.DimDateFile
                                  WHERE [Fiscal Month Indicator] = 0 or [Fiscal Month Indicator] = -1) FiscalMonths
                                ON  CustItemMonthlyPlacements.[YearMonth] = FiscalMonths.[FiscalYearPeriod]
                        LEFT JOIN
                            AFISales_Enh.MrktSpclstAcctOwnershipSlsCat 
                                ON DimItemMaster.AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                                   AND CustItemMonthlyPlacements.CustomerNumber = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                                   AND CustItemMonthlyPlacements.ShiptoNumber = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                                   AND DimItemMaster.AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
                        LEFT JOIN
                            AFISales_DW.DimSalesTerritories            T1
                                ON T1.[AFI Sales Region Code] = ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, CAST('Z' AS CHAR(3)))
                                   AND T1.[AFI Sales RepID] = ISNULL(MrktSpclstAcctOwnershipSlsCat.RepID, CAST('ZZZZZ' AS CHAR(3)))
                                   AND T1.[AFI Sales Category] = ISNULL(DimItemMaster.AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
                                   AND T1.[Active Record] = 1
                        LEFT JOIN
                            AFISales_DW.DimSalesTerritories            T2
                                ON T2.[AFI Sales Region Code] = CAST('Z' AS CHAR(3))
                                   AND T2.[AFI Sales RepID] = CAST('ZZZZZ' AS CHAR(5))
                                   AND T2.[AFI Sales Category] = ISNULL(DimItemMaster.AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
                                   AND T2.[Active Record] = 1
                    WHERE
                            FiscalMonths.[Fiscal Month Indicator] = 0        -- current month
                            OR  FiscalMonths.[Fiscal Month Indicator] = -1   --previous month 
                    GROUP BY
                            CustItemMonthlyPlacements.ItemSKU,
                            COALESCE(T1.SalesTerritoryID, T2.SalesTerritoryID),
                            CustItemMonthlyPlacements.CustomerNumber,
                            CustItemMonthlyPlacements.ShiptoNumber
                ) t1
            GROUP BY
                t1.ItemSKU,
                t1.[SalesTerritoryID],
                t1.[CustomerNumber],
                t1.[ShiptoNumber],
                t1.RepID,
                t1.[MonthlyQuantity]
        )                                 t2
    LEFT JOIN
        AFISales_DW.[DimSalesTerritories] 
            ON t2.SalesTerritoryID = DimSalesTerritories.SalesTerritoryID;


