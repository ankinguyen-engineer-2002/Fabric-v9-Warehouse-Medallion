CREATE VIEW [SSAS_AFISALES_OLAP].[FactPotential]
AS
    SELECT
            [AFI Sales Category]     AS [Sales Category],
            [Marketing Specialist ID],
            [AFI Sales Region Code]  AS [Region Code],
            [AFI Sales RepID]        AS Territory,
            RegionCode_RepID_Category,
            WeekEndingDate           AS [Week Ending Date],
            AddressID                AS [Address ID],
            SalesTerritoryID,
            MarketPotential          AS [Market Potential]
    FROM
            AFISales_DW.[FactPotential] SP
        LEFT JOIN
            AFISales_DW.DimDateFile     D
                ON SP.WeekEndingDate = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO