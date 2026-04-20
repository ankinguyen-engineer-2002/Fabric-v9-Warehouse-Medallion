CREATE VIEW [SSAS_AFISALES_OLAP].[FactSpeedToMarket]
AS
    SELECT
            [Invoice Date],
            [Request Date],
            [Delivery Date],
            [Order Date],
            SH.[Account And Shipto Number],
            Territory,
            ST.RegionCode_RepID_Category,
            [Customer Account Number]      AS [Account Number],
            [Customer Shipto Number]       AS [Shipto Number],
            [Invoice Number],
            [Order Number],
            [Item SKU],
            SH.[Store Address ID],
            SH.[Shipto AddressID],
            ST.[Marketing Specialist ID]   AS [Sales Repid],
            [AFI Sales Region Code]        AS [Sales Region Code],
            [Warehouse],
            [Item Status],
            [Order Item Status],
            ST.[AFI Sales Category],
            [Speed To Market Base],
            [Speed to Market],
            [Delivery Days],
            [Stm Base Calc],
            [Stm Count],
            [Early],
            [On Time],
            [1 Day Late],
            [2 Days Late],
            [3 Days Late],
            [4 Days Late],
            [5 Days Late],
            [6 Days Late],
            [7 Days Late],
            [8 to 14 Days Late],
            [15 to 21 Days Late],
            [22 to 28 Days Late],
            [Over 28 Days Late],
            [AFI Sales Division Code]      AS [Division Code],
            RTRIM(C.[Customer Account Number]) + '-' + RTRIM(C.[Customer Shipto Number]) + '-'
            + ST.[AFI Sales Division Code] AS [Customer Shipto Division Number],
            [Promise Date]                 AS [Promised Date],
            [Delivery Days - Promised]     AS [Speed to Market - Promised],
            [Delivery Days - Promised],
            [Early - Promised],
            [On Time - Promised],
            [1 Day Late - Promised],
            [2 Days Late - Promised],
            [3 Days Late - Promised],
            [4 Days Late - Promised],
            [5 Days Late - Promised],
            [6 Days Late - Promised],
            [7 Days Late - Promised],
            [8 to 14 Days Late - Promised],
            [15 to 21 Days Late - Promised],
            [22 to 28 Days Late - Promised],
            [Over 28 Days Late - Promised],
            SH.SalesTerritoryID
    FROM
            AFISales_DW.FactShippedHistory    SH
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories] ST
                ON SH.SalesTerritoryID = ST.SalesTerritoryID
        LEFT JOIN
            AFISales_DW.DimCustomers          C
                ON SH.[Account And Shipto Number] = C.[Account And Shipto Number]
    WHERE
            [Delivery Days] IS NOT NULL
            AND [Invoice Credit Code] = ''
            AND [Request Date] IS NOT NULL
            AND [Quantity Shipped] <> 0;