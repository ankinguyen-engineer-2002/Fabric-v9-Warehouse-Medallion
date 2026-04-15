CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_Aggregated]
AS
    SELECT
        SubQuery.*
    FROM
        (
            SELECT
                    DivisionVPKey,
                    DivisionMSKey,
                    ST.[AFI Alternate Division],
                    ST.[AFI Sales Region Type],
                    ST.[Sales Regional VP],
                    ST.[Marketing Specialist],
                    (TRIM(OH.[Account And Shipto Number]) + '' + ST.[Marketing Specialist]) AS Associate,
                    OH.[Account And Shipto Number],
                    OH.[Item SKU],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [PY]
                                    AND [Fiscal Week] = [LW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       )                                                                    [WP_PY_LW],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [CY]
                                    AND [Fiscal Week] = [LW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       )                                                                    [WP_CY_LW],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [PY]
                                    AND [Fiscal Week] = [CW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       )                                                                    [WP_PY_CW],
                    SUM(   CASE
                               WHEN [Fiscal Year] = [CY]
                                    AND [Fiscal Week] = [CW]
                                   THEN
                                   [Current Placements]
                               ELSE
                                   0
                           END
                       )                                                                    [WP_CY_CW]
            FROM
                    AFISales_DW.FactWeeklyPlacements OH
                LEFT JOIN
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
                    )                                                        ST
                        ON OH.[SalesTerritoryID] = ST.[SalesTerritoryID]
                LEFT JOIN
                    [PowerBI_Wholesale].[DateFile_Yesterday]                 DT
                        ON OH.[Week Ended] = DT.[Transaction Date]
            GROUP BY
                    DivisionVPKey,
                    DivisionMSKey,
                    ST.[AFI Alternate Division],
                    ST.[AFI Sales Region Type],
                    ST.[Sales Regional VP],
                    ST.[Marketing Specialist],
                    (TRIM(OH.[Account And Shipto Number]) + '' + ST.[Marketing Specialist]),
                    OH.[Account And Shipto Number],
                    OH.[Item SKU]
        ) AS SubQuery;

GO