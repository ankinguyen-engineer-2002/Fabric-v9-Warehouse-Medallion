CREATE VIEW [AFISales_DW_Wrk].[v_FactMarketCommitments_Current]
  AS 

SELECT
        ROW_NUMBER() OVER (ORDER BY RepID)                                    AS RowID,
        MarketCommitments.Market                                              AS Market,
        MarketCommitments.RepID                                               AS MarketingSpecialist,
        MarketCommitments.ItemSKU                                             AS ItemSKU,
        'ASHLEY_' + MarketCommitments.ItemSKU                                 AS [Item Key],
        MarketCommitments.CustomerNumber                                      AS [CustomerNumber],
        MarketCommitments.ShiptoNumber                                        AS [ShiptoNumber],
        T1.[AFI Sales RepID]                                                  AS [Territory],
        COALESCE(T1.[SalesTerritoryID], T2.[SalesTerritoryID])                AS [SalesTerritoryID],
        MarketLookup.Code                                                     AS [MarketCode],
        MarketCommitments.UserId                                              AS [User ID],
        MarketCommitments.Commitment + MarketCommitments.HomestoreCommitment  AS [Market Commitment],
        MarketCommitments.Commitment                                          AS [Market Commitment - NonHomestore],
        MarketCommitments.HomestoreCommitment                                 AS [Market Commitment - Homestore],
        MarketCommitments.MonthlyEstQty                                       AS [Monthly Estimate],
        MarketCommitments.HomestoreQty                                        AS [MonthlyQuantity],
        CASE
            WHEN MarketCommitments.CustomerNumber = ''
                THEN
                'All Customers'
            ELSE
                MarketCommitments.CustomerNumber
        END                                                    AS [Account]
FROM
        [$(Wholesale_Warehouse)].Marketing.MarketCommitments
    LEFT JOIN
        AFISales_DW.DimItemMaster       
            ON MarketCommitments.ItemSKU = DimItemMaster.ItemSKU
    LEFT JOIN
        [$(Wholesale_Warehouse)].Marketing.MarketLookup
            ON MarketLookup.MarketID = MarketCommitments.Market
    LEFT JOIN
        AFISales_DW.DimSalesTerritories   T1
            ON T1.[AFI Sales Region Code] = ISNULL(MarketCommitments.Region, CAST('Z' AS CHAR(3)))
               AND T1.[AFI Sales RepID] = ISNULL(MarketCommitments.RepID, CAST('ZZZZZ' AS CHAR(5)))
               AND T1.[AFI Sales Category] = ISNULL(DimItemMaster.AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
               AND T1.[Active Record] = 1
    LEFT JOIN
        AFISales_DW.DimSalesTerritories   T2
            ON T2.[AFI Sales Region Code] = CAST('Z' AS CHAR(3))
               AND T2.[AFI Sales RepID] = CAST('ZZZZZ' AS CHAR(5))
               AND T2.[AFI Sales Category] = ISNULL(DimItemMaster.AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
               AND T2.[Active Record] = 1
    JOIN
        AFISales_DW.[DimSalesTerritories] 
            ON COALESCE(T1.[SalesTerritoryID], T2.[SalesTerritoryID]) = DimSalesTerritories.SalesTerritoryID
WHERE
        DimSalesTerritories.[Marketing Specialist ID] <> 'N/A';




