CREATE VIEW [SSAS_AFISALES_OLAP].[FactMonthlyPlacements]
AS
    SELECT
            -1                               AS [Goal Id],
            [AFI Sales Category]             AS [Sales Category],
            [AFI Sales Division Code]        AS [AFI Sales Division],
            [AFI Sales Region Code]          AS [AFI Sales Region],
            [AFI Sales RepID]                AS [Marketing Specialist ID],
            [RegionCode_RepID_Category],
            [AFI Sales Division Code]        AS [Division Code],
            [Customer Account Number],
            [Customer Shipto Number],
            [Account And Shipto Number],
            [Customer Shipto Division Number],
            [Territory],
            [Store Address ID],
            [Shipto AddressID],
            [Item SKU],
            [Item Status],
            [Month Ended],
            [Net Placement Gain],
            [Monthly Quantity],
            [Placement Gain],
            [Placement Loss],
            [Current Placements],
            [At Risk Placements],
            [MTD Quantity],
            [MTD Placements],
            SalesTerritoryID
    FROM
            AFISales_DW.[FactMonthlyPlacements] MP
        LEFT JOIN
            AFISales_DW.DimDateFile             D
                ON MP.[Month Ended] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO


