CREATE VIEW AFISales_DW_Wrk.v_FactOpenOrders
AS
    SELECT
            CAST(ROW_NUMBER() OVER (ORDER BY
                                        Orders.CustomerNumber
                                   ) AS BIGINT)        RowID,
            Orders.[Order Taken Date],
            CAST(Orders.[Order Number] AS VARCHAR(10)) AS [Order Number],
            Orders.[Item Sequence Number],
            [Account And Shipto Number]                = CAST(CASE
                                                                  WHEN Orders.ShiptoNumber IS NULL
                                                                       OR Orders.ShiptoNumber = ''
                                                                      THEN
                                                                      Orders.CustomerNumber
                                                                  ELSE
                                                                      RTRIM(Orders.CustomerNumber) + '-' + LTRIM(Orders.ShiptoNumber)
                                                              END AS VARCHAR(13)),
            [Customer Account Number]                  = Orders.CustomerNumber,
            [Customer Shipto Number]                   = Orders.ShiptoNumber,
            [SalesTerritoryID],
            [Territory]                                = Orders.Territory,
            [Item Key]                                 = 'ASHLEY_' + ISNULL(Orders.ItemSKU, ''),
            [Item Sku]                                 = ISNULL(Orders.ItemSKU, ''),
            [Sales Division Code]                      = Orders.Division,
            [Billto Address ID]                        = Orders.StoreAddressID,
            [Shipto Address ID]                        = Orders.RouteAddressID,
            [Warehouse]                                = ISNULL(Orders.Warehouse, ''),
            [Item Status]                              = CAST(Orders.ItemStatus AS CHAR(3)),
            [Sales Category Code]                      = CAST(Orders.SalesCategory AS CHAR(3)),
            [Open Order Amount]                        = CAST(Orders.OpenOrderAmt * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)),
            [Open Order Quantity]                      = CAST(Orders.OpenOrderQty * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)),
            [Back Order Amount]                        = CAST(Orders.BackOrderAmt * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)),
            [Order Arrival Mode]                       = Orders.OrderArrival,
            [Back Order Quantity]                      = CAST(Orders.BackOrderQty * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)),
            [Original Promise Date],
            [Current Promise Date],
            [Estimated Delivery Date] ,
            COALESCE([Initial Promise Date],[Original Promise Date]) as [Initial Promise Date],
            [Original Request Date],
            [Current Request Date],
            [Primary Order Type],
            [Secondary Order Type],
            [3rd Order Type],
            [4th Order Type],
            [Inventory Allocated Flag],
            [Current Load Date],
            [Count of Load Date Changes],
            [Load Lead Time],
            [Shipping Instructions],
            [RegionCode_RepID_Cat]                     = DimSalesTerritories.[RegionCode_RepID_Category],
            [Sales Region Code]                        = DimSalesTerritories.[AFI Sales Region Code],
            [Sales Rep ID]                             = DimSalesTerritories.[AFI Sales RepID],
            [Customer SKU/Package]                     = Orders.GroupSKU,
            [Customer Shipto Division Number]          = RTRIM(   CASE
                                                                      WHEN Orders.ShiptoNumber IS NULL
                                                                           OR Orders.ShiptoNumber = ''
                                                                          THEN
                                                                          RTRIM(Orders.CustomerNumber) + '-'
                                                                      ELSE
                                                                          RTRIM(Orders.CustomerNumber) + '-'
                                                                          + LTRIM(Orders.ShiptoNumber)
                                                                  END
                                                              ) + '-' + Orders.Division,
            [Open Order Discounts]                     = CAST((Orders.[Order Discount])
                                                              * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)), -- Rev 10
            [Open Order Freight]                       = CAST((Orders.[Order Freight] * Orders.OpenOrderQty)
                                                              * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)), -- Rev 10


            [Trip Number(s)]                           = CAST(Orders.TripNo AS VARCHAR(650)),
            [Customer PO]                              = Orders.PurchaseOrder
    FROM
            (
                SELECT
                        OpenOrderHeader.OrderDate                                        AS [Order Taken Date],
                        OpenOrderDetail.[OrderNumber]                                    AS [Order Number],
                        OpenOrderDetail.[ItemSequence]                                   AS [Item Sequence Number],
                        OpenOrderDetail.CustomerNumber                                   AS CustomerNumber,
                        OpenOrderDetail.ShiptoNumber                                     AS ShiptoNumber,
                        OpenOrderExtendedItem.Discount + OpenOrderExtendedItem.DFIDiscount                                  AS [Order Discount],
                        OpenOrderExtendedItem.Freight                                                   AS [Order Freight],
                        DimCustomers.[Store Address ID]                                  AS StoreAddressID,
                        DimCustomers.[Shipto AddressID]                                  AS RouteAddressID,
                        OpenOrderDetail.ItemSKU                                          AS ItemSKU,
                        AFISalesDivisionCode                                             AS Division,
                        DimGeographicLocations.[Msa Fips Code]                           AS MsaFips,
                        OpenOrderDetail.Warehouse                                        AS Warehouse,
                        AFIItemStatus                                                    AS ItemStatus,
                        CASE
                            WHEN CAST([Shipto Sales Territory] AS INT) = 0
                                THEN
                                [Primary Sales Territory]
                            ELSE
                                [Primary Sales Territory] + [Shipto Sales Territory]
                        END                                                              AS Territory,
                        CASE
                            WHEN CAST([Shipto Sales Territory] AS INT) = 0
                                THEN
                                [Primary Sales Territory]
                            ELSE
                                [Shipto Sales Territory]
                        END                                                              AS DefaultTerritory,
                        OpenOrderDetail.QuantiyOrdered - OpenOrderDetail.QuantityShipped AS OpenOrderQty,
                        OpenOrderDetail.QuantityBackOrdered                              AS BackOrderQty,
                        AFISalesCategoryCode                                             AS SalesCategory,
                        ((ISNULL(OpenOrderDetail.NetSalesAmount, 0) / CASE
                                                                 WHEN ISNULL(OpenOrderDetail.QuantityBackOrdered, 0) > 0
                                                                     THEN
                                                                     ISNULL(OpenOrderDetail.QuantityBackOrdered, 0)
                                                                 ELSE
                        (CASE
                             WHEN ISNULL(OpenOrderDetail.QuantiyOrdered, 0) > 0
                                 THEN
                                 ISNULL(OpenOrderDetail.QuantiyOrdered, 0)
                             ELSE
                                 1
                         END
                        )
                                                             END
                         ) - ISNULL(OpenOrderExtendedItem.Freight, 0)
                        ) * CASE
                                WHEN ISNULL(OpenOrderDetail.QuantityBackOrdered, 0) > 0
                                    THEN
                                    ISNULL(OpenOrderDetail.QuantityBackOrdered, 0)
                                ELSE
                        (CASE
                             WHEN ISNULL(OpenOrderDetail.QuantiyOrdered, 0) > 0
                                 THEN
                                 ISNULL(OpenOrderDetail.QuantiyOrdered, 0)
                             ELSE
                                 1
                         END
                        )
                            END                                                          AS OpenOrderAmt, --Modified by saravanan Date 05-18-19 
                        CASE
                            WHEN ISNULL(OpenOrderDetail.QuantityBackOrdered, 0) > 0
                                THEN
                        ((ISNULL(OpenOrderDetail.NetSalesAmount, 0) / ISNULL(OpenOrderDetail.QuantityBackOrdered, 0))
                         - ISNULL(OpenOrderExtendedItem.Freight, 0)
                        ) * ISNULL(OpenOrderDetail.QuantityBackOrdered, 0)
                            ELSE
                                0
                        END                                                              AS BackOrderAmt,
                        ExtendedOrder.OrderArrivalCode                                   AS OrderArrival,
                        0                                                                AS StandardCost,
                        OpenOrderExtendedItem.PromiseDate                                AS [Original Promise Date],
                        OpenOrderDetail.PromiseDate                                      AS [Current Promise Date],
                        OpenOrderDetail.PromiseDate                                      AS [Estimated Delivery Date] ,
                        T6.RequestDate                                                   AS [Initial Promise Date] ,
                        ExtendedOrder.RouteFreezeDate                                    AS [Original Request Date],
                        ExtendedOrder.RequestDate                                        AS [Current Request Date],
                        T1.Description                                                   AS [Primary Order Type] ,
                        T2.Description                                                   AS [Secondary Order Type],
                        T3.Description                                                   AS [3rd Order Type], 
                        T4.Description                                                   AS [4th Order Type] ,
                        OpenOrderDetail.[ItemAllocationFlag]                             AS [Inventory Allocated Flag],
                        OpenOrderDetail.LoadDate                                         AS [Current Load Date],
                        OpenOrderDetail.[LoadDateChangeCount]                            AS [Count of Load Date Changes],
                        OpenOrderHeader.[ShippingLeadTime]                               AS [Load Lead Time],
                        OpenOrderHeader.[ShippingInstructions]                           AS [Shipping Instructions],
                        CASE
                            WHEN OpenOrderDetail.ItemDescription = OpenOrderDetail.ItemLanguageDescription
                                THEN
                                ''
                            ELSE
                                OpenOrderDetail.ItemLanguageDescription
                        END                                                              AS GroupSKU,
                        T5.TripNumber                                                    AS TripNo,
                        OpenOrderHeader.PurchaseOrder

                FROM
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderDetail
                    LEFT JOIN
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderExtendedItem
                            ON (
                                   OpenOrderDetail.OrderNumber = OpenOrderExtendedItem.OrderNumber
                                   AND OpenOrderDetail.ItemSequence = OpenOrderExtendedItem.SequenceNumber
                               )
                    JOIN
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.OpenOrderHeader
                            ON (OpenOrderDetail.OrderNumber = OpenOrderHeader.OrderNumber)
                    JOIN
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.ExtendedOrder
                            ON (OpenOrderDetail.OrderNumber = ExtendedOrder.OrderNumber)
                    LEFT JOIN
                        (
                            SELECT
                                CustomerNumber,
                                OrderNumber,
                                ItemSKU,
                                ItemSequence,
                                STRING_AGG(TripNumber, ', ') AS TripNumber
                            FROM
                                [$(Distribution_Warehouse)].Transportation.TripDetail
                            GROUP BY
                                CustomerNumber,
                                OrderNumber,
                                ItemSKU,
                                ItemSequence
                        )                                          T5
                            ON (
                                   OpenOrderDetail.CustomerNumber = T5.CustomerNumber
                                   AND OpenOrderDetail.OrderNumber = T5.OrderNumber
                                   AND OpenOrderDetail.ItemSKU = T5.ItemSKU
                                   AND OpenOrderDetail.ItemSequence = T5.ItemSequence
                               )
                    LEFT JOIN
                        (
                            SELECT CustomerNumber,
                                OrderNumber,
                                ItemSKU,
                                ItemSequence,
                                Min(RequestDate) as RequestDate
                            FROM [$(Wholesale_Warehouse)].SalesHistory_AFI.[OrderHistory]
                            GROUP BY CustomerNumber,
                                OrderNumber,
                                ItemSKU,
                                ItemSequence
                        )                                                 T6
                            ON (
                                OpenOrderDetail.CustomerNumber = T6.CustomerNumber
                                AND OpenOrderDetail.OrderNumber = T6.OrderNumber
                                AND OpenOrderDetail.ItemSKU = T6.ItemSKU
                                AND OpenOrderDetail.ItemSequence = T6.ItemSequence
                            )
                    LEFT JOIN
                        AFISales_DW.DimCustomers
                            ON DimCustomers.[Customer Account Number] = OpenOrderDetail.CustomerNumber
                               AND DimCustomers.[Customer Shipto Number] = OpenOrderDetail.ShiptoNumber
                    LEFT JOIN
                        AFISales_DW.DimGeographicLocations
                            ON DimCustomers.[Shipto AddressID] = DimGeographicLocations.[Address ID]
                    JOIN
                        AFISales_DW.DimItemMaster
                            ON DimItemMaster.ItemSKU = OpenOrderDetail.ItemSKU
                    LEFT JOIN
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode T1
                            ON T1.OrderTypeCode = ExtendedOrder.[OrderType1]
                    LEFT JOIN
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode T2
                            ON T2.OrderTypeCode = ExtendedOrder.[OrderType2]
                    LEFT JOIN
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode T3
                            ON T3.OrderTypeCode = ExtendedOrder.[OrderType3]
                    LEFT JOIN
                        [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode T4
                            ON T4.OrderTypeCode = ExtendedOrder.[OrderType4]
                WHERE
                        (
                            OpenOrderDetail.QuantityBackOrdered <> 0
                            OR OpenOrderDetail.QuantiyOrdered <> 0
                        )
                        AND OpenOrderDetail.BasePrice <> 0
                        AND OpenOrderHeader.ActiveRecord <> 'X'
                        AND OpenOrderDetail.QuantiyOrdered >= 0
            ) Orders
        LEFT JOIN
            AFISales_Enh.TerritoryAllocationStatic
                ON Orders.DefaultTerritory = TerritoryAllocationStatic.TerritoryCode
                   AND Orders.SalesCategory = TerritoryAllocationStatic.SalesCategory
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
                   AND DimSalesTerritories.[AFI Sales Category] = ISNULL(
                                                                            TerritoryAllocationStatic.SalesCategory,
                                                                            CAST('ZZ' AS CHAR(3))
                                                                        )
                   AND DimSalesTerritories.[Active Record] = 1;




