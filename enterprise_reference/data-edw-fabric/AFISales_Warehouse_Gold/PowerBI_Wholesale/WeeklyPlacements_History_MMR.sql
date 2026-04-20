CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements_History_MMR]
AS
    SELECT
            C.[AFI Alternate Division],
            C.[AFI Sales Region Type],
            C.[Sales Regional VP],
            C.[Marketing Specialist],
            Cust.[Reporting Business Type],
            [ProductLine]               AS [Product Line],
            [ImportDomesticCode]        AS [Import Domestic Code],
            [ABC Account-Current Year]  AS [ABC Account- Current Year],
            [Fiscal Year],
            [Fiscal Week],
            SUM(A.[Current Placements]) AS [Current Placements]
    FROM
            AFISales_DW.[FactWeeklyPlacements] A
        JOIN
            AFISales_DW.[DimCustomers]         Cust
                ON A.[Account And Shipto Number] = Cust.[Account And Shipto Number]
        JOIN
            AFISales_DW.[DimSalesTerritories]  C
                ON A.[SalesTerritoryID] = C.[SalesTerritoryID]
        JOIN
            AFISales_DW.[DimItemMaster]        IM
                ON A.[Item SKU] = IM.[ItemSKU]
        JOIN
            PowerBI_Wholesale.DateFile                                 D
                ON A.[Week Ended] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= [PY] - 2
            AND [Fiscal Year] < [PY]
            AND [Reporting Business Type] = 'Primary'
    GROUP BY
            C.[AFI Alternate Division],
            C.[AFI Sales Region Type],
            C.[Sales Regional VP],
            C.[Marketing Specialist],
            Cust.[Reporting Business Type],
            [ProductLine],
            [ImportDomesticCode],
            [ABC Account-Current Year],
            [Fiscal Year],
            [Fiscal Week];
GO