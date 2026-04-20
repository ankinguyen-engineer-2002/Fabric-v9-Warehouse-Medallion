CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_Last3Years]
AS
    SELECT
            DivisionVPKey,
            DivisionMSKey,
            WP.[Account And Shipto Number],
            [AFI Alternate Division],
            [AFI Sales Region Type],
            [Marketing Specialist],
            (TRIM(WP.[Account And Shipto Number]) + '' + [Marketing Specialist]) Associate,
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week],
            SUM(WP.[Current Placements])                                         [Weekly Current Placements]
    FROM
            (
                SELECT
                        SalesTerritoryID,
                        [Account And Shipto Number],
                        [Item SKU],
                        CAST([Fiscal Year] AS INT)  [Fiscal Year],
                        CAST([Fiscal Month] AS INT) [Fiscal Month],
                        CAST([Fiscal Week] AS INT)  [Fiscal Week],
                        [Current Placements]
                FROM
                        AFISales_DW.FactWeeklyPlacements FWP
                    INNER JOIN
                        PowerBI_Wholesale.DateFile_Yesterday                     D
                            ON FWP.[Week Ended] = D.[Transaction Date]
                WHERE
                        D.[Fiscal Year] >= [PY] - 1
            ) WP
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
            ) F
                ON WP.SalesTerritoryID = F.SalesTerritoryID
    GROUP BY
            DivisionVPKey,
            DivisionMSKey,
            WP.[Account And Shipto Number],
            [AFI Alternate Division],
            [AFI Sales Region Type],
            [Marketing Specialist],
            (TRIM(WP.[Account And Shipto Number]) + '' + [Marketing Specialist]),
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week];
GO

