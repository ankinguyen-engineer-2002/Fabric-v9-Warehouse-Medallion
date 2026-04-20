CREATE VIEW [SSAS_AFISALES_OLAP].[FactMarketing]
AS
    SELECT
            M.[Velocity Driver Key],
            M.[Ad Funds Key],
            M.SalesTerritoryID,
            M.Territory,
            M.[Account And Shipto Number],
            M.MarketDate,
            M.VelocityDriverCount,
            M.AdFundsRequested,
            M.AdFundsApproved,
            M.[Account Number],
            M.[Shipto Number],
            M.[Division Code],
            M.[Customer Shipto Division Number],
            ST.RegionCode_RepID_Category
    FROM
            AFISales_DW.FactMarketing       M
        LEFT JOIN
            AFISales_DW.DimSalesTerritories ST
                ON ST.SalesTerritoryID = M.SalesTerritoryID
        LEFT JOIN
            AFISales_DW.DimDateFile         D
                ON M.MarketDate = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO