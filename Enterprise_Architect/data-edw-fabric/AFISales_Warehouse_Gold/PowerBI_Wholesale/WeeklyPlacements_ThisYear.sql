CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_ThisYear]
AS
    SELECT
            DivisionVPKey,
            DivisionMSKey,
            [AFI Alternate Division],
            [AFI Sales Region Type],
            [Sales Regional VP],
            [Marketing Specialist],
            (TRIM(WP_SubQuery.[Account And Shipto Number]) + '' + ST.[Marketing Specialist]) Associate,
            WP_SubQuery.[Account And Shipto Number],
            [Item SKU],
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week],
            SUM(WP_SubQuery.[Current Placements])                                            [Weekly Current Placements],
            SUM([Placement Gain])                                                            AS [Placement Gain],
            SUM([Placement Loss])                                                            AS [Placement Loss]
    FROM
            (
                SELECT
                        SalesTerritoryID,
                        [Account And Shipto Number],
                        [Item SKU],
                        CAST([Fiscal Year] AS INT)  [Fiscal Year],
                        CAST([Fiscal Month] AS INT) [Fiscal Month],
                        CAST([Fiscal Week] AS INT)  [Fiscal Week],
                        [Current Placements],
                        [Placement Gain],
                        [Placement Loss]
                FROM
                        AFISales_DW.FactWeeklyPlacements FWP
                    INNER JOIN
                        PowerBI_Wholesale.DateFile_Yesterday                     D
                            ON FWP.[Week Ended] = D.[Transaction Date]
                WHERE
                        [CY YTD Flag] = 1
            ) WP_SubQuery
        INNER JOIN
            (
                SELECT
                    [SalesTerritoryID],
                    [AFI Alternate Division],
                    [AFI Sales Region Type],
                    [Sales Regional VP],
                    [Marketing Specialist],
                    ([AFI Alternate Division] + '' + [AFI Sales Region Type] + '' + [Sales Regional VP] + ''
                     + [Marketing Specialist]
                    )                                                                                       AS DivisionVPKey,
                    ([AFI Alternate Division] + '' + [AFI Sales Region Type] + '' + [Marketing Specialist]) AS DivisionMSKey
                FROM
                    AFISales_DW.DimSalesTerritories
                WHERE
                    [Active Record] = 1
            ) ST
                ON WP_SubQuery.SalesTerritoryID = ST.SalesTerritoryID
    GROUP BY
            DivisionVPKey,
            DivisionMSKey,
            [AFI Alternate Division],
            [AFI Sales Region Type],
            [Sales Regional VP],
            [Marketing Specialist],
            (TRIM(WP_SubQuery.[Account And Shipto Number]) + '' + ST.[Marketing Specialist]),
            WP_SubQuery.[Account And Shipto Number],
            [Item SKU],
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week];
GO