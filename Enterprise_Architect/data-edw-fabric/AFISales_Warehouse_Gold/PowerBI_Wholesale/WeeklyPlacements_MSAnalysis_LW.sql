CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_MSAnalysis_LW]
AS
    SELECT
        SubQuery.*
    FROM
        (
            SELECT
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP],
                    ST.[Marketing Specialist],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [PY]
                                    AND [Fiscal Week] = [LW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       ) [WP_PY_LW],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [CY]
                                    AND [Fiscal Week] = [LW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       ) [WP_CY_LW]
            FROM
                    AFISales_DW.FactWeeklyPlacements OH
                INNER JOIN
                    (
                        SELECT DISTINCT
                               [Account And Shipto Number],
                               [Customer Account Number]
                        FROM
                               AFISales_DW.DimCustomers
                        WHERE
                               [Reporting Business Type] <> 'Ashley HomeStores'
                    )                                                         C
                        ON OH.[Account And Shipto Number] = C.[Account And Shipto Number]
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories  ST
                        ON OH.[SalesTerritoryID] = ST.[SalesTerritoryID]
                LEFT JOIN
                    [PowerBI_Wholesale].[DateFile_Yesterday]                  DT
                        ON OH.[Week Ended] = DT.[Transaction Date]
            GROUP BY
                    ST.[AFI Alternate Division],
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP],
                    ST.[Marketing Specialist]
            UNION
            SELECT
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP],
                    'All' [Marketing Specialist],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [PY]
                                    AND [Fiscal Week] = [LW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       )  [WP_PY_LW],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [CY]
                                    AND [Fiscal Week] = [LW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       )  [WP_CY_LW]
            FROM
                    AFISales_DW.FactWeeklyPlacements OH
                INNER JOIN
                    (
                        SELECT DISTINCT
                               [Account And Shipto Number],
                               [Customer Account Number]
                        FROM
                               AFISales_DW.DimCustomers
                        WHERE
                               [Reporting Business Type] <> 'Ashley HomeStores'
                    )                                                         C
                        ON OH.[Account And Shipto Number] = C.[Account And Shipto Number]
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories  ST
                        ON OH.[SalesTerritoryID] = ST.[SalesTerritoryID]
                LEFT JOIN
                    [PowerBI_Wholesale].[DateFile_Yesterday]                  DT
                        ON OH.[Week Ended] = DT.[Transaction Date]
            GROUP BY
                    ST.[AFI Alternate Division],
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP]
        ) AS SubQuery
    WHERE
        [WP_PY_LW] <> 0
        OR [WP_CY_LW] <> 0;