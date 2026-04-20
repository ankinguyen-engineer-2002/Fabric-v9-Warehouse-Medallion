CREATE VIEW [SSAS_AFISALES_OLAP].[FactSpecials]
AS
    SELECT
            [RowID],
            [Account And Shipto Number],
            [Shipto AddressID],
            [Customer Shipto Division Number],
            Territory,
            [Order Number],
            [Purchase Order],
            [Item Key]                       AS [Item SKU],
            [Warehouse],
            [Special Discount Code]          = [Specials Discount Code],
            [Special Discount]               = [Specials Discount],
            [Gross Price]                    = [Specials Gross Price],
            [Quantity Ordered]               = [Specials Quantity],
            [Order Date],
            [New Discount Percentage],
            SalesTerritoryID
    FROM
            AFISales_DW.FactSpecials FS
        LEFT JOIN
            AFISales_DW.DimDateFile  D
                ON FS.[Order Date] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO