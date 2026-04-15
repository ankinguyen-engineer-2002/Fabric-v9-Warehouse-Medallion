CREATE VIEW AFISales_DW_Wrk.v_FactMarketing 
AS
SELECT
        ROW_NUMBER() OVER (ORDER BY
                                 DimSalesTerritories.SalesTerritoryID
                             )                   AS [Velocity Driver Key],
        RequestID                                                                                        AS [Ad Funds Key],
        DimSalesTerritories.SalesTerritoryID,
        CASE
            WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                THEN
                DimCustomers.[Primary Sales Territory]
            ELSE
                DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
        END                                                                                              AS Territory,
        DimCustomers.[Account And Shipto Number],
        CAST(DATEADD(dd, DATEDIFF(dd, 0, AdFundsRequest.ApprovedOn), 0) AS DATE)                            AS MarketDate,
        NULL                                                                                             AS VelocityDriverCount,
        (
            SELECT
                AdFundsRequest.Amount
            FROM
                [$(Wholesale_Warehouse)].Marketing.[AFValueList] 
            WHERE
                (
                    AFValueList.ValueType = 'Fund Status'
                    OR AFValueList.ValueType = 'FundStatus'
                )
                AND AFValueList.ValueDescription = 'Submitted'
                AND AFValueList.ValueCode = AdFundsRequest.Status
        )                                                                                                AS [AdFundsRequested],
        (
            SELECT
                AdFundsRequest.Amount
            FROM
                [$(Wholesale_Warehouse)].Marketing.[AFValueList] 
            WHERE
                (
                    AFValueList.ValueType = 'Fund Status'
                    OR AFValueList.ValueType = 'FundStatus'
                )
                AND AFValueList.ValueCode = AdFundsRequest.Status
        )                                                                                                AS [AdFundsApproved],
        CAST(AdFundsRequest.CustomerNumber AS VARCHAR(8))                                                    AS [Account Number],
        AdFundsRequest.ShiptoNumber                                                                         AS [Shipto Number],
        AdFundsRequest.Division                                                                             AS [Division Code],
        RTRIM(ISNULL(AdFundsRequest.CustomerNumber, '')) + '-' + RTRIM(ISNULL(AdFundsRequest.ShiptoNumber, '')) + '-Z' [Customer Shipto Division Number],
        DimSalesTerritories.RegionCode_RepID_Category
FROM
        [$(Wholesale_Warehouse)].Marketing.[AdFundsRequest]        
    LEFT JOIN
        [$(Wholesale_Warehouse)].Marketing.[AFValueList] 
            ON AFValueList.ValueCode = AdFundsRequest.Status
    LEFT JOIN
        AFISales_DW.DimSalesTerritories
            ON DimSalesTerritories.RegionCode_RepID_Category = 'Z-ZZZZZ-ZZ'
               AND DimSalesTerritories.[Active Record] = 1 ---Division codes in source data are invalid
    LEFT JOIN
        AFISales_DW.DimCustomers
            ON AdFundsRequest.CustomerNumber = DimCustomers.[Customer Account Number]
               AND ISNULL(AdFundsRequest.ShiptoNumber, '') = DimCustomers.[Customer Shipto Number]
WHERE
        (
            AFValueList.ValueType = 'FundStatus'
            OR AFValueList.ValueType = 'Fund Status'
        )
        AND AdFundsRequest.ApprovedOn IS NOT NULL