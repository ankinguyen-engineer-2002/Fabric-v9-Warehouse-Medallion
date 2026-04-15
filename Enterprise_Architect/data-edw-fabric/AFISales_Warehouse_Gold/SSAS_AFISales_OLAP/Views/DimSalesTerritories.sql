CREATE VIEW [SSAS_AFISALES_OLAP].[DimSalesTerritories]
AS
    SELECT
        SalesTerritoryID,
        [AFI Sales Division Code],
        [AFI Sales Division],
        [AFI Sales Region Code],
        [AFI Sales RepID],
        [AFI Sales Region],
        [AFI Sales Region Type],
        [Marketing Specialist ID],
        [Marketing Specialist],
        [AFI Sales Category],
        [AFI Sales Category Name],
        [AFI Alternate Division Code],
        [AFI Alternate Division],
        [Sales Regional VP],
        [Sales Division President],
        [Product Line],
        [Active Record],
        [Business Name],
        RegionCode_RepID_Category,
        [Marketing Specialist Mail ID],
        [AFI Sales Region Type] AS [Region Type]
    FROM
        AFISales_DW.DimSalesTerritories;