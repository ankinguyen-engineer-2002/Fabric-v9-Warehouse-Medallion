CREATE VIEW [AFISales_DW_Wrk].[v_FactDailyPlacementsSaved]
AS
    SELECT
            ROW_NUMBER() OVER (ORDER BY T1.ItemSKU)                   AS RowID,
            'ASHLEY_' + T1.[ItemSKU]  AS [Item Key],
            T1.[ItemSKU],
            DimSalesTerritories.[SalesTerritoryID],
            CAST(T1.[OrderDate] AS DATE) AS [Order Date],
            T1.[ShiptoAddressID]         AS [Shipto AddressID],
            T1.[AccountAndShiptoNumber]  AS [Account And Shipto Number],
            CASE
                WHEN CAST([Shipto Sales Territory] AS INT) = 0
                    THEN
                    [Primary Sales Territory]
                ELSE
                    [Primary Sales Territory] + [Shipto Sales Territory]
            END                             AS Territory,
            ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)             AS [Is Saved],
            DimSalesTerritories.RegionCode_RepID_Category     AS [RegionCode RepID Category],
            RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number]) + '-'
            + DimSalesTerritories.[AFI Sales Division Code]   AS [Customer Shipto Division Number],
            DimCustomers.[Customer Account Number],
            DimCustomers.[Customer Shipto Number],
            DimSalesTerritories.[AFI Sales Division Code]
    FROM
            (
                SELECT
                        ROW_NUMBER() OVER (ORDER BY
                                               [DailyPlacementsSaved].[CustomerNumber],
                                               [DailyPlacementsSaved].[ShiptoNumber],
                                               [DailyPlacementsSaved].[ItemSKU],
                                               [DailyPlacementsSaved].[OrderDate]
                                          )                                                                 AS RowID,
                        [DailyPlacementsSaved].[CustomerNumber],
                        [DailyPlacementsSaved].[ShiptoNumber],
                        [DailyPlacementsSaved].[ItemSKU],
                        [DailyPlacementsSaved].[OrderDate],
                        CAST(CAST(DimDateFile.[Fiscal Year] AS VARCHAR) + '-' + CAST(DimDateFile.[Fiscal Month] AS VARCHAR) + '-1' AS DATE) AS [Check Date],
                        [DailyPlacementsSaved].[ShiptoAddressID],
                        [DailyPlacementsSaved].[AccountAndShiptoNumber],
                        [DailyPlacementsSaved].[SalesCategory]
                FROM
                        AFISales_Enh.DailyPlacementsSaved
                    JOIN
                        AFISales_DW.DimDateFile
                            ON [DailyPlacementsSaved].[OrderDate] = [Transaction Date]
                GROUP BY
                        [DailyPlacementsSaved].[CustomerNumber],
                        [DailyPlacementsSaved].[ShiptoNumber],
                        [DailyPlacementsSaved].[ItemSKU],
                        DimDateFile.[Fiscal Year],
                        DimDateFile.[Fiscal Month],
                        [DailyPlacementsSaved].[OrderDate],
                        [DailyPlacementsSaved].[ShiptoAddressID],
                        [DailyPlacementsSaved].[AccountAndShiptoNumber],
                        [DailyPlacementsSaved].[SalesCategory]
                HAVING
                        SUM([DailyPlacementsSaved].[Quantity]) <> 0
            )                                 T1
        LEFT JOIN
            (
                SELECT
                        ROW_NUMBER() OVER (ORDER BY
                                               [DailyPlacementsSaved].[CustomerNumber],
                                               [DailyPlacementsSaved].[ShiptoNumber],
                                               [DailyPlacementsSaved].[ItemSKU],
                                               [DailyPlacementsSaved].[OrderDate]
                                          )                                                                 AS RowID,
                        [DailyPlacementsSaved].[ItemSKU],
                        [DailyPlacementsSaved].[CustomerNumber],
                        [DailyPlacementsSaved].[OrderDate],
                        [DailyPlacementsSaved].[ShiptoNumber],
                        CAST(CAST(DimDateFile.[Fiscal Year] AS VARCHAR) + '-' + CAST(DimDateFile.[Fiscal Month] AS VARCHAR) + '-1' AS DATE) AS [Check Date],
                        [DailyPlacementsSaved].[ShiptoAddressID],
                        [DailyPlacementsSaved].[AccountAndShiptoNumber],
                        [DailyPlacementsSaved].[SalesCategory]
                FROM
                        AFISales_Enh.DailyPlacementsSaved
                    JOIN
                        AFISales_DW.DimDateFile
                            ON DailyPlacementsSaved.OrderDate = DimDateFile.[Transaction Date]
                GROUP BY
                        [DailyPlacementsSaved].[CustomerNumber],
                        [DailyPlacementsSaved].[ShiptoNumber],
                        [DailyPlacementsSaved].[ItemSKU],
                        DimDateFile.[Fiscal Year],
                        DimDateFile.[Fiscal Month],
                        [DailyPlacementsSaved].[OrderDate],
                        [DailyPlacementsSaved].[ShiptoAddressID],
                        [DailyPlacementsSaved].[AccountAndShiptoNumber],
                        [DailyPlacementsSaved].[SalesCategory]
                HAVING
                        SUM([DailyPlacementsSaved].[Quantity]) <> 0
            )                                 T2
                ON T2.RowID = (T1.RowID - 1)
                   AND T2.[ItemSKU] = T1.[ItemSKU]
                   AND T2.[CustomerNumber] = T1.[CustomerNumber]
                   AND T2.[ShiptoNumber] = T1.[ShiptoNumber]
        LEFT JOIN
            AFISales_DW.DimCustomers          
                ON DimCustomers.[Account And Shipto Number] = T1.[AccountAndShiptoNumber]
        LEFT JOIN
            AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
            ON   T1.CustomerNumber = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                AND T1.ShiptoNumber = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                AND T1.SalesCategory = MrktSpclstAcctOwnershipSlsCat.SalesCategory
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories] 
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, CAST('Z' AS CHAR(3)))
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(MrktSpclstAcctOwnershipSlsCat.RepID, CAST('ZZZZZ' AS CHAR(5)))
                   AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                    WHEN ISNULL(MrktSpclstAcctOwnershipSlsCat.SalesCategory, '') = ''
                                                         OR ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, '') = ''
                                                        THEN
                                                        CAST('ZZ' AS CHAR(3))
                                                    ELSE
                                                        MrktSpclstAcctOwnershipSlsCat.SalesCategory
                                                END
                   AND DimSalesTerritories.[Active Record] = 1
    WHERE
            DATEDIFF(MONTH, T2.[Check Date], T1.[Check Date]) = 3;
