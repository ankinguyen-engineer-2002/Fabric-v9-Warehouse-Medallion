CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_WeeklySales]
AS
    SELECT
            [Account And Shipto Number],
            [ItemGrouping],
            [Marketing Specialist],
            [AFI Sales Region Type]                                   AS [Region Type],
            [Sales Regional VP],
            [AFI Alternate Division],
            AFIFinanceDivision,
            [Marketing Specialist] + '' + [AFI Sales Region Type] + '' + [Sales Regional VP] + ''
            + [AFI Alternate Division]                                AS Key4,
            [Marketing Specialist] + '' + [Account And Shipto Number] AS Key5,
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week],
            SUM([Current Placements])                                 [Current Placements]
    FROM
            (
                SELECT
                        [Account And Shipto Number],
                        [Item SKU],
                        [SalesTerritoryID],
                        [Fiscal Year],
                        [Fiscal Month],
                        [Fiscal Week],
                        SUM([Current Placements]) AS [Current Placements]
                FROM
                        AFISales_DW.FactWeeklyPlacements WP
                    LEFT JOIN
                        AFISales_DW.DimDateFile                              c
                            ON WP.[Week Ended] = c.[Transaction Date]
                WHERE
                        c.[Fiscal Year Indicator] >= -2
                        AND c.[Fiscal Year Indicator] <= 0 --AND c.[Transaction Date] <= getdate() 
                GROUP BY
                        [Account And Shipto Number],
                        [Item SKU],
                        [SalesTerritoryID],
                        [Fiscal Year],
                        [Fiscal Month],
                        [Fiscal Week]
            )                                                       a
        LEFT JOIN
            (
                SELECT
                    ItemSKU,
                    ItemGrouping,
                    AFIFinanceDivision,
                    ItemThirdPartyItem,
                    [MarketIntroducedAt]
                FROM
                    AFISales_DW.[DimItemMaster]
            )                                                       b
                ON a.[Item SKU] = b.ItemSKU
        LEFT JOIN
            AFISales_DW.DimSalesTerritories c
                ON a.SalesTerritoryID = c.SalesTerritoryID
    WHERE
            (
                ItemThirdPartyItem = 'False'
                OR ItemThirdPartyItem IS NULL
            )
            AND [MarketIntroducedAt] <> 'Supplier Direct Ship'
    GROUP BY
            [Account And Shipto Number],
            [ItemGrouping],
            [Marketing Specialist],
            [AFI Sales Region Type],
            [Sales Regional VP],
            [AFI Alternate Division],
            AFIFinanceDivision,
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week];
GO