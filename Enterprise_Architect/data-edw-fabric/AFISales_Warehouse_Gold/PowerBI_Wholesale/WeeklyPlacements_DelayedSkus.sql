CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_DelayedSkus]
AS
    SELECT
            [AFI Alternate Division],
            [Reporting Business Type],
            [Item SKU],
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week],
            SUM(WP_SubQuery.[Current Placements]) [Weekly Current Placements]
    FROM
            (
                SELECT
                        SalesTerritoryID,
                        [Reporting Business Type],
                        [Item SKU],
                        CAST([Fiscal Year] AS INT)  [Fiscal Year],
                        CAST([Fiscal Month] AS INT) [Fiscal Month],
                        CAST([Fiscal Week] AS INT)  [Fiscal Week],
                        [Current Placements]
                FROM
                        AFISales_DW.FactWeeklyPlacements FWP
                    INNER JOIN
                        AFISales_DW.DimCustomers         C
                            ON FWP.[Account And Shipto Number] = C.[Account And Shipto Number]
                    INNER JOIN
                        PowerBI_Wholesale.DateFile_Yesterday                     D
                            ON FWP.[Week Ended] = D.[Transaction Date]
                WHERE
                        D.[Fiscal Year] >= [PY]
            )                                                       WP_SubQuery
        LEFT JOIN
            AFISales_DW.DimSalesTerritories ST
                ON WP_SubQuery.SalesTerritoryID = ST.SalesTerritoryID
    GROUP BY
            [AFI Alternate Division],
            [Reporting Business Type],
            [Item SKU],
            [Fiscal Year],
            [Fiscal Month],
            [Fiscal Week];

GO