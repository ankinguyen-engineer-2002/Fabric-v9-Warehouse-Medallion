CREATE VIEW [SSAS_AFISALES_OLAP].[FactDailyPlacementsSaved]
AS
    SELECT
        [Customer Account Number]        AS [Customer Number],
        [Customer Shipto Number]         AS [Ship Number],
        [Item SKU]                       AS [Item Number],
        [Order Date],
        [Shipto AddressID],
        [Account And Shipto Number]      AS [Account And ShiptoNumber],
        [Territory],
        [RegionCode RepID Category],
        [Is Saved],
        [AFI Sales Division Code]        AS [Division Code],
        [Customer Shipto Division Number],
        [SalesTerritoryID]
    FROM
        AFISales_DW.[FactDailyPlacementsSaved];
GO