CREATE VIEW [SSAS_AFISALES_OLAP].[FactOnTimeDelivery]
AS
    SELECT
            [AFI Warehouse],
            [Trip Number],
            [Invoice Date],
            [Customer Number]                   = OT.[Customer Account Number],
            [Shipto Number]                     = OT.[Customer Shipto Number],
            OT.[Account And Shipto Number],
            OT.[AFI Sales RepID]                AS [Sales Repid],
            OT.[AFI Sales Region Code]          AS [Sales Region Code],
            ST.RegionCode_RepID_Category,
            SUBSTRING([Item Key], 8, 15)        AS [Item SKU],
            C.[Store Address ID],
            C.[Shipto AddressID],
            [Item Status],
            ST.[AFI Sales Category]             AS [Sales Category],
            OT.[Route Zone],
            OT.[Route Region],
            [Order Type],
            [Shipped Quantity],
            [Order to Delivery],
            [Originl Promise to Delivery],
            [Invoice To Delivery],
            [Current Request to Delivery],
            [First Scan to Trip Close],
            [Trip Close to Delivery],
            [Original Request to Delivery],
            [Order to First Scan],
            [Trip Create to Trip Close],
            [Trip Create to First Scan],
            [Order to Trip Create],
            [Current Promise to Delivery],
            [Qty Ontime - Original Promise Day],
            [Qty Ontime - Original Promise Week],
            [Qty Ontime - Current Request Day],
            [Qty Ontime - Current Request Week],
            [Qty Ontime - Original Request Day],
            [Qty Ontime - Original Request Week],
            [Qty Ontime - Current Promise Day],
            [Qty Ontime - Current Promise Week],
            OT.SalesTerritoryID
    FROM
            AFISales_DW.[FactOnTimeDelivery]  OT
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories] ST
                ON OT.SalesTerritoryID = ST.SalesTerritoryID
        LEFT JOIN
            AFISales_DW.DimCustomers          C
                ON OT.[Account And Shipto Number] = C.[Account And Shipto Number];