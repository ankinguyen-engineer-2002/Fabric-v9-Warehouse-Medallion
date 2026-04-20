CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_MSAnalysis]
AS
    SELECT
        SubQuery.*
    FROM
        (
            SELECT
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP],
                    ST.[Marketing Specialist],
                    OH.[Account And Shipto Number],
                    C.[Customer Account Number],
                    [ABC Account-Current Year],
                    [Account Exception Flag],
                    SUM([Current Placements]) [Current Placements]
            FROM
                    AFISales_DW.FactWeeklyPlacements OH
                LEFT JOIN
                    AFISales_DW.DimCustomers         C
                        ON OH.[Account And Shipto Number] = C.[Account And Shipto Number]
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories  ST
                        ON OH.[SalesTerritoryID] = ST.[SalesTerritoryID]
            GROUP BY
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP],
                    ST.[Marketing Specialist],
                    OH.[Account And Shipto Number],
                    C.[Customer Account Number],
                    [ABC Account-Current Year],
                    [Account Exception Flag]
            UNION
            SELECT
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP],
                    'All'                     [Marketing Specialist],
                    OH.[Account And Shipto Number],
                    C.[Customer Account Number],
                    [ABC Account-Current Year],
                    [Account Exception Flag],
                    SUM([Current Placements]) [Current Placements]
            FROM
                    AFISales_DW.FactWeeklyPlacements OH
                LEFT JOIN
                    AFISales_DW.DimCustomers         C
                        ON OH.[Account And Shipto Number] = C.[Account And Shipto Number]
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories  ST
                        ON OH.[SalesTerritoryID] = ST.[SalesTerritoryID]
            GROUP BY
                    ST.[AFI Alternate Division],
                    ST.[Sales Regional VP],
                    OH.[Account And Shipto Number],
                    C.[Customer Account Number],
                    [ABC Account-Current Year],
                    [Account Exception Flag]
        ) AS SubQuery
    WHERE
        [Current Placements] <> 0;