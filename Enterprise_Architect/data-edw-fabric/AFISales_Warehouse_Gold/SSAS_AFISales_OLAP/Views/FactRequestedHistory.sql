CREATE VIEW [SSAS_AFISALES_OLAP].[FactRequestedHistory]
AS
    SELECT
            ST.[AFI Sales Category],
            [AFI Sales Division Code]      AS [Division Code],
            [AFI Sales Region Code]        AS [Sales Region Code],
            [AFI Sales RepID]              AS [Sales Repid],
            RegionCode_RepID_Category,
            C.[Customer Account Number]    AS [Customer Number],
            C.[Customer Shipto Number]     AS [Shipto Number],
            RTRIM(C.[Customer Account Number]) + '-' + RTRIM(C.[Customer Shipto Number]) + '-'
            + ST.[AFI Sales Division Code] AS [Customer Shipto Division Number],
            [Request Date],
            [Order Number],
            [Order Sequence],
            C.[Account And Shipto Number],
            [Territory],
            [Item SKU],
            C.[Store Address ID],
            C.[Shipto AddressID],
            OH.[SalesTerritoryID],
            [Goal ID],
            [Week End Date],
            [Warehouse],
            [Item Status],
            [Quantity Ordered]             AS [Quantity Requested],
            [Amount Ordered]               AS [Amount Requested]
    FROM
            AFISales_DW.FactOrderHistory    OH
        LEFT JOIN
            AFISales_DW.DimSalesTerritories ST
                ON OH.SalesTerritoryID = ST.SalesTerritoryID
        LEFT JOIN
            AFISales_DW.DimCustomers        C
                ON OH.[Account And Shipto Number] = C.[Account And Shipto Number]
        LEFT JOIN
            AFISales_DW.DimDateFile         D
                ON OH.[Request Date] = D.[Transaction Date]
    WHERE
            [Fiscal Year] >= YEAR(GETDATE()) - 4;
GO