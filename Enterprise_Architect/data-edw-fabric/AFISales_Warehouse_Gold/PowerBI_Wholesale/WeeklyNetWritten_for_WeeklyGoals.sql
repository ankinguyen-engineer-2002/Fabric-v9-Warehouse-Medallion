CREATE VIEW [PowerBI_Wholesale].[WeeklyNetWritten_for_WeeklyGoals]
AS
    SELECT
        SubQuery.*
    FROM
        (
            SELECT   (ST.[AFI Alternate Division] + '' + C.[Reporting Business Type]) AS DivisionChannelKey,
                     ST.[AFI Alternate Division],
                     C.[Reporting Business Type],
                     ST.[AFI Sales Region Type],
                     ST.[Sales Regional VP],
                     ST.[Marketing Specialist],
                     [Fiscal Year],
                     [Fiscal Month],
                     [Fiscal Week],
                     SUM([Amount Ordered])                                            [Amount Ordered]
            FROM
                     AFISales_DW.FactOrderHistory             OH
                LEFT JOIN
                     AFISales_DW.DimCustomers                 C
                         ON OH.[Account And Shipto Number] = C.[Account And Shipto Number]
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
                     )                                        ST
                         ON OH.[SalesTerritoryID] = ST.[SalesTerritoryID]
                LEFT JOIN
                     [PowerBI_Wholesale].[DateFile_Yesterday] DT
                         ON OH.[Order Change Date] = DT.[Transaction Date]
            WHERE
                     [Fiscal Year] = [CY]
            GROUP BY (ST.[AFI Alternate Division] + '' + C.[Reporting Business Type]),
                     ST.[AFI Alternate Division],
                     C.[Reporting Business Type],
                     ST.[AFI Sales Region Type],
                     ST.[Sales Regional VP],
                     ST.[Marketing Specialist],
                     [Fiscal Year],
                     [Fiscal Month],
                     [Fiscal Week]
            UNION
            SELECT (ST.[AFI Alternate Division] + '' + C.[Reporting Business Type]) AS DivisionChannelKey,
                   ST.[AFI Alternate Division],
                   C.[Reporting Business Type],
                   ST.[AFI Sales Region Type],
                   ST.[Sales Regional VP],
                   ST.[Marketing Specialist],
                   [Fiscal Year],
                   [Fiscal Month],
                   [Fiscal Week],
                   NULL                                                             AS [Amount Ordered]
            FROM
                   (
                       SELECT DISTINCT
                              [Reporting Business Type]
                       FROM
                              AFISales_DW.DimCustomers
                   ) C ,
                (
                    SELECT DISTINCT
                           [AFI Alternate Division],
                           [AFI Sales Region Type],
                           [Sales Regional VP],
                           [Marketing Specialist]
                    FROM
                           AFISales_DW.DimSalesTerritories
                ) ST ,
                (
                    SELECT DISTINCT
                           [Fiscal Year],
                           [Fiscal Month],
                           [Fiscal Week]
                    FROM
                           [PowerBI_Wholesale].[DateFile_Yesterday]
                    WHERE
                           [Fiscal Year] = [CY]
                           AND [Fiscal Week] >= [CW]
                ) DT
        ) AS SubQuery;