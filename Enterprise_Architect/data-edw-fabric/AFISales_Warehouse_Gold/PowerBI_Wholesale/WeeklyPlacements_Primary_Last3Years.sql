CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_Primary_Last3Years]
AS
    SELECT
        sq.*
    FROM
        (
            SELECT
                    B.[Fiscal Year],
                    B.[Fiscal Week],
                    C.[AFI Alternate Division],
                    D.[ImportDomesticCode],
                    D.[ProductLine],
                    C.[AFI Sales Region Type]   AS [Region Type],
                    C.[Marketing Specialist],
                    E.[Reporting Business Type],
                    E.[ABC Account-Current Year],
                    D.[ItemSKU],
                    SUM(A.[Current Placements]) AS Placements
            FROM
                    AFISales_DW.[FactWeeklyPlacements] A
                LEFT JOIN
                    AFISales_DW.[DimDateFile]          B
                        ON A.[Week Ended] = B.[Transaction Date]
                LEFT JOIN
                    AFISales_DW.[DimSalesTerritories]  C
                        ON C.[SalesTerritoryID] = A.[SalesTerritoryID]
                LEFT JOIN
                    AFISales_DW.[DimItemMaster]        D
                        ON A.[Item SKU] = D.[ItemSKU]
                LEFT JOIN
                    AFISales_DW.[DimCustomers]         E
                        ON A.[Account And Shipto Number] = E.[Account And Shipto Number]
            WHERE
                    E.[Reporting Business Type] = 'Primary'
                    AND B.[Fiscal Year] >= YEAR(GETDATE() - 1) - 2
            GROUP BY
                    B.[Fiscal Year],
                    B.[Fiscal Week],
                    C.[AFI Alternate Division],
                    D.[ImportDomesticCode],
                    D.[ProductLine],
                    C.[AFI Sales Region Type],
                    C.[Marketing Specialist],
                    E.[Reporting Business Type],
                    E.[ABC Account-Current Year],
                    D.[ItemSKU]
        ) sq
    WHERE
        Placements <> 0;