CREATE VIEW [SSAS_AFISALES_OLAP].[FactOpenOrders]
AS
    SELECT
            [Order Taken Date],
            [Invoice Date]                   = [Order Taken Date], --- added for backword compatability for AFISALES_OLAP
            [Customer Number]                = C.[Customer Account Number],
            [Shipto Number]                  = C.[Customer Shipto Number],
            OP.[Account And Shipto Number],
            [Territory],
            I.[Item SKU],
            [Store Address ID],
            [Shipto AddressID],
            ST.[RegionCode_RepID_Category],
            [Sales Repid]                    = [AFI Sales RepID],
            [Sales Region Code]              = [AFI Sales Region Code],
            [Warehouse],
            [Item Status]                    = [AFI Item Status],
            [AFI Sales Category]             = [AFI Sales Category Code],
            [Open Order Amount],
            [Open Order Quantity],
            [Division Code]                  = I.[AFI Sales Division Code],
            [Customer Shipto Division Number],
            OP.SalesTerritoryID
    FROM
            AFISales_DW.FactOpenOrders       OP
        JOIN
            SSAS_AFISALES_OLAP.DimItemMaster I
                ON SUBSTRING(OP.[Item Key], 8, 15) = I.[Item SKU]
        JOIN
            AFISales_DW.DimSalesTerritories  ST
                ON OP.SalesTerritoryID = ST.SalesTerritoryID
        LEFT JOIN
            AFISales_DW.DimCustomers         C
                ON OP.[Account And Shipto Number] = C.[Account And Shipto Number];