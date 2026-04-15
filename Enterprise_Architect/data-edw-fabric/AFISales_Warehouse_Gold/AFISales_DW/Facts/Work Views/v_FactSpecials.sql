CREATE VIEW [AFISales_DW_Wrk].[v_FactSpecials]
AS
    SELECT
            ROW_NUMBER() OVER (ORDER BY
                                  OpenOrderHeader.OrderNumber 
                             )                   AS RowID,
            [SalesTerritoryID],
            DimCustomers.[Account And Shipto Number],
            CASE
                WHEN CAST([Shipto Sales Territory] AS INT) = 0
                    THEN
                    [Primary Sales Territory]
                ELSE
                    [Primary Sales Territory] + [Shipto Sales Territory]
            END                                                                                                 AS Territory,
            OpenOrderHeader.OrderNumber                                                                                        AS [Order Number] ,
            NULL                                                                                                AS [Invoice Number],
            NULL                                                                                                AS [Invoice Date],
            DimCustomers.[Store Address ID]                                                                     AS [Billto Address ID],
            DimCustomers.[Shipto AddressID]                                                                     AS [Shipto AddressID],
            OpenOrderHeader.PurchaseOrder                                                                       AS [Purchase Order]    ,
            RTRIM(DimItemMaster.ItemSKU)                                                                        AS [Item Key],
            [Warehouse]                                                                                         = ISNULL(OpenOrderHeader.Warehouse, ''),
            [Specials Discount Code]                                                                            = CASE
                                                                                                                      WHEN LEFT(OpenOrderComments.Comment1, 2) = '>S'
                                                                                                                          THEN
                                                                                                                          OpenOrderComments.Comment1
                                                                                                                      WHEN LEFT(OpenOrderComments.Comment2, 2) = '>S'
                                                                                                                          THEN
                                                                                                                          OpenOrderComments.Comment2
                                                                                                                      ELSE
                                                                                                                          OpenOrderComments.Comment3
                                                                                                                  END,
            [Specials Discount Adj Code]                                                                        = DiscountAdjustmentCode,
            CAST(OpenOrderDetail.QuantiyOrdered - OpenOrderDetail.QuantityShipped * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)) AS [Specials Quantity],
            OpenOrderHeader.OrderDate                                                                                           AS [Order Date],
            CASE
                WHEN CAST((OpenOrderDetail.SellingPrice + OpenOrderExtendedItem.Discount - OpenOrderExtendedItem.Freight) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                          * (OpenOrderDetail.QuantiyOrdered - OpenOrderDetail.QuantityShipped) AS DECIMAL(12,4)) = 0
                    THEN
                    '0.00'
                ELSE
            ((CAST((OpenOrderDetail.SellingPrice + OpenOrderExtendedItem.Discount - OpenOrderExtendedItem.Freight) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                   * (OpenOrderDetail.QuantiyOrdered - OpenOrderDetail.QuantityShipped) AS DECIMAL(12,4)) 
             )
            )
            END                                                                                                 AS [Specials Gross Price],
            ((CAST((OpenOrderDetail.SellingPrice + OpenOrderExtendedItem.Discount - OpenOrderExtendedItem.Freight) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                   * (OpenOrderDetail.QuantiyOrdered - OpenOrderDetail.QuantityShipped) AS DECIMAL(12,4))
             ) * OpenOrderDetail.[DiscountPercent]
            )                                                                                                   AS [Specials Discount],
            OpenOrderDiscounts.[DiscountPercent]                                                                          AS [New Discount Percentage],
            DimCustomers.[Customer Account Number]                                                              AS [Customer Number] ,  
            DimCustomers.[Customer Shipto Number]                                                               AS [Shipto Number] ,
            DimSalesTerritories.RegionCode_RepID_Category,
            RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number]) + '-'
            + DimSalesTerritories.[AFI Sales Division Code]                                                     AS [Customer Shipto Division Number],
            DimCustomers.[Store Address ID]
    FROM
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderComments 
        JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderHeader  
                ON OpenOrderHeader.OrderNumber = OpenOrderComments.OrderNumber
        JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderDetail 
                ON OpenOrderHeader.OrderNumber = OpenOrderDetail.OrderNumber
        JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderExtendedItem 
                ON OpenOrderExtendedItem.OrderNumber = OpenOrderHeader.OrderNumber
                   AND OpenOrderExtendedItem.SequenceNumber = ItemSequence
        JOIN
            AFISales_DW.DimItemMaster
                ON DimItemMaster.ItemSKU = OpenOrderDetail.ItemSKU
        LEFT JOIN
            AFISales_DW.DimCustomers
                ON [Customer Account Number] = OpenOrderHeader.CustomerNumber
                   AND [Customer Shipto Number] = OpenOrderHeader.ShiptoNumber
        JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderDiscounts
                ON OpenOrderDiscounts.OrderNumber = OpenOrderHeader.OrderNumber
                   AND OpenOrderDiscounts.ItemSKU = OpenOrderDetail.ItemSKU
                   AND OpenOrderDiscounts.ItemSequence = OpenOrderDetail.ItemSequence
                   AND OpenOrderDiscounts.DiscountAdjustmentCode IN (
                                                        'MSC', 'QTP', 'SSP', 'NPS'
                                                    )
        LEFT JOIN
            AFISales_Enh.TerritoryAllocationStatic
                ON CASE
                       WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) <> 0
                           THEN
                           [Shipto Sales Territory]
                       ELSE
                           [Primary Sales Territory]
                   END = TerritoryAllocationStatic.TerritoryCode
                   AND AFISalesCategoryCode = TerritoryAllocationStatic.SalesCategory
        LEFT JOIN
            AFISales_DW.DimSalesTerritories
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(
                                                                           TerritoryAllocationStatic.RegionCode,
                                                                           CAST('Z' AS CHAR(3))
                                                                       )
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(
                                                                         TerritoryAllocationStatic.RepID,
                                                                         CAST('ZZZZZ' AS CHAR(5))
                                                                     )
                   AND DimSalesTerritories.[AFI Sales Category] = ISNULL(AFISalesCategoryCode, CAST('ZZ' AS CHAR(3)))
                   AND DimSalesTerritories.[Active Record] = 1
    WHERE
            OpenOrderHeader.ActiveRecord <> 'X'
            AND
                (
                    SUBSTRING(OpenOrderComments.Comment1, 1, 2) = '>S'
                    OR SUBSTRING(OpenOrderComments.Comment2, 1, 2) = '>S'
                    OR SUBSTRING(OpenOrderComments.Comment3, 1, 2) = '>S'
                )
    UNION ALL
    SELECT
            [SalesTerritoryID],
            DimCustomers.[Account And Shipto Number],
            CASE
                WHEN CAST([Shipto Sales Territory] AS INT) = 0
                    THEN
                    [Primary Sales Territory]
                ELSE
                    [Primary Sales Territory] + [Shipto Sales Territory]
            END                                                                                                     AS Territory,
            [Order Number]                                                                                          = OrderComments.OrderNumber,
            [Order Sequence]                                                                                        = OrderComments.OrderSequence,
            [Invoice Number]                                                                                        = OrderComments.InvoiceNumber,
            [Invoice Date]                                                                                          = OrderComments.InvoiceDate,
            DimCustomers.[Store Address ID]                                                                         AS [Billto Address ID],
            DimCustomers.[Shipto AddressID],
            [Purchase Order]                                                                                        = InvoiceHeader.[PurchaseOrder],
            RTRIM(InvoiceDetail.ItemSKU)                                                                         AS [Item Key],
            [Warehouse]                                                                                             = ISNULL(InvoiceHeader.[Warehouse], ''),
            [Special Discount Code]                                                                                 = CASE
                                                                                                                          WHEN SUBSTRING(OrderComments.OrderComment1, 1, 2) = '>S'
                                                                                                                              THEN
                                                                                                                              OrderComments.OrderComment1
                                                                                                                          WHEN SUBSTRING(OrderComments.OrderComment2, 1, 2) = '>S'
                                                                                                                              THEN
                                                                                                                              OrderComments.OrderComment2
                                                                                                                          ELSE
                                                                                                                              OrderComments.OrderComment3
                                                                                                                      END,
            [Specials Discount Adj Code]                                                                            = ShippedHistoryDiscounts.[DiscountAdjustmentCode],
            CAST([QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)) AS [Quantity Ordered],
            InvoiceHeader.[OrderDate]                                                                               AS [Order Date],
            CASE
                WHEN CAST(([Price] + [Discount] - [Freight]) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                          * [QuantityShipped] AS DECIMAL(12,4)) = 0
                    THEN
                    '0.00'
                ELSE
            ((CAST(([Price] + [Discount] - [Freight]) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                   * [QuantityShipped] AS DECIMAL(12,4))
             )
            )
            END                                                                                                     AS [Market Specials Gross Price],
            ((CAST(([Price] + [Discount] - [Freight]) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                   * [QuantityShipped] AS DECIMAL(12,4))
             ) * ShippedHistoryDiscounts.[DiscountPercent]
            )                                                                                                       AS [Special Discount],
            ShippedHistoryDiscounts.[DiscountPercent]                                                               AS [New Discount Percentage],
            [Customer Number]                                                                                       = DimCustomers.[Customer Account Number],
            [Shipto Number]                                                                                         = DimCustomers.[Customer Shipto Number],
            DimSalesTerritories.RegionCode_RepID_Category,
            RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number]) + '-'
            + DimSalesTerritories.[AFI Sales Division Code]                                                         AS [Customer Shipto Division Number],
            DimCustomers.[Store Address ID]
    FROM
            [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderComments
        JOIN
            [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceHeader
                ON OrderComments.[InvoiceNumber] = InvoiceHeader.[InvoiceNumber]
                   AND InvoiceHeader.InvoiceDate = OrderComments.[InvoiceDate]
                   AND InvoiceHeader.[CustomerNumber] = OrderComments.[CustomerNumber]
                   AND InvoiceHeader.[ShiptoNumber] = OrderComments.[ShiptoNumber]
        JOIN
            [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                ON InvoiceHeader.[InvoiceNumber] = InvoiceDetail.[InvoiceNumber]
                   AND InvoiceHeader.[CustomerNumber] = InvoiceDetail.[CustomerNumber]
                   AND InvoiceHeader.[ShiptoNumber] = InvoiceDetail.[ShiptoNumber]
                   AND InvoiceHeader.[InvoiceDate] = InvoiceDetail.[InvoiceDate]
        JOIN
            AFISales_DW.DimItemMaster
                ON DimItemMaster.ItemSKU = InvoiceDetail.ItemSKU
        LEFT JOIN
            AFISales_DW.DimCustomers
                ON [Customer Account Number] = InvoiceHeader.[CustomerNumber]
                   AND [Customer Shipto Number] = InvoiceHeader.[ShiptoNumber]
        LEFT JOIN
            AFISales_Enh.TerritoryAllocationStatic
                ON CASE
                       WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) <> 0
                           THEN
                           [Shipto Sales Territory]
                       ELSE
                           [Primary Sales Territory]
                   END = TerritoryAllocationStatic.TerritoryCode
                   AND DimItemMaster.AFISalesCategoryCode = TerritoryAllocationStatic.SalesCategory
        JOIN
            [$(Wholesale_Warehouse)].SalesHistory_AFI.ShippedHistoryDiscounts
                ON ShippedHistoryDiscounts.[InvoiceNumber] = InvoiceDetail.[InvoiceNumber]
                   AND ShippedHistoryDiscounts.[OrderNumber] = InvoiceDetail.[OrderNumber]
                   AND ShippedHistoryDiscounts.[ItemSKU] = InvoiceDetail.ItemSKU
                   AND ShippedHistoryDiscounts.[ItemSequence] = InvoiceDetail.ItemSequence
                   AND [DiscountAdjustmentCode] IN (
                                                       'MSC', 'QTP', 'SSP', 'NPS'
                                                   )
        LEFT JOIN
            AFISales_DW.DimSalesTerritories
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(
                                                                           TerritoryAllocationStatic.RegionCode,
                                                                           CAST('Z' AS CHAR(3))
                                                                       )
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(
                                                                         TerritoryAllocationStatic.RepID,
                                                                         CAST('ZZZZZ' AS CHAR(5))
                                                                     )
                   AND DimSalesTerritories.[AFI Sales Category] = ISNULL([AFISalesCategoryCode], CAST('ZZ' AS CHAR(3)))
                   AND DimSalesTerritories.[Active Record] = 1
    WHERE
            (
                SUBSTRING(OrderComments.OrderComment1, 1, 2) = '>S'
                OR SUBSTRING(OrderComments.OrderComment2, 1, 2) = '>S'
                OR SUBSTRING(OrderComments.OrderComment3, 1, 2) = '>S'
            )
            AND InvoiceDetail.[QuantityShipped] <> 0;
