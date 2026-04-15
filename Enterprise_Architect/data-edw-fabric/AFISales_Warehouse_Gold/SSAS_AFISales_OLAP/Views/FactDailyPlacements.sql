CREATE VIEW [SSAS_AFISALES_OLAP].[FactDailyPlacements]
AS
    SELECT
            [AFI Sales Region Code]          AS dopRegion,
            [AFI Sales RepID]                AS dopRepid,
            [Customer Account Number]        AS dopCustomerNumber,
            [Customer Shipto Number]         AS dopShiptoNumber,
            [Item SKU]                       AS dopItemNumber,
            [AFI Sales Category],
            [Daily Placement],
            [Daily Placement for Risk Calc],
            [Placement Date],
            [Store Address ID],
            [Shipto AddressID],
            [Account And Shipto Number],
            [Territory],
            [RegionCode_RepID_Category],
            [AFI Sales Division Code]        AS [Division Code],
            [Customer Shipto Division Number],
            [SalesTerritoryID]
    FROM
            AFISales_DW.[FactDailyPlacements] DP
        LEFT JOIN
            AFISales_DW.DimDateFile           D
                ON DP.[Placement Date] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO


