CREATE VIEW [SSAS_AFISALES_OLAP].[FactAccountGrowthRate]
AS
    SELECT
            [AccountShiptoNumber]           AS [Account And Shipto Number],
            [AddressID]                     AS [Address ID],
            ST.[RegionCode_RepID_Category]  AS [RegionCode_RepID_Category],
            [PrevYearAmountOrdered]         AS [Prev YTD Amount Ordered],
            [CurrentYearAmountOrdered]      AS [Current YTD Amount Ordered],
            [PrevYearMonthAmountOrdered]    AS [Prev MTD Amount Ordered],
            [CurrentYearMonthAmountOrdered] AS [Current MTD Amount Ordered],
            [PrevYearWeekAmountOrdered]     AS [Prev WTD Amount Ordered],
            [CurrentYearWeekAmountOrdered]  AS [Current WTD Amount Ordered],
            AG.SalesTerritoryID
    FROM
            AFISales_DW.FactAccountGrowthRate AG
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories] ST
                ON AG.SalesTerritoryID = ST.SalesTerritoryID;