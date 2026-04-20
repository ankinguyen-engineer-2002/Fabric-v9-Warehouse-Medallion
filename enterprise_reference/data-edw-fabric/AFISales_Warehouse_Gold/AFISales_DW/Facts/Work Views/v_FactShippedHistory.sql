CREATE VIEW [AFISales_DW_Wrk].[v_FactShippedHistory]
AS
    WITH PackageComments
    AS (
           SELECT
               [InvoiceNumber],
               [ItemSequence],
               MAX(SUBSTRING(ItemComments1, 6, 30)) AS PackageSKU,
               [InvoiceDate]
           FROM
               [$(Wholesale_Warehouse)].SalesHistory_AFI.ItemComments
           WHERE
               SUBSTRING(ItemComments1, 1, 4) = 'PKG:'
           GROUP BY
               [InvoiceNumber],
               [ItemSequence],
               [InvoiceDate])
    SELECT
        ROW_NUMBER() OVER (ORDER BY [Invoice Number]) AS RowID,
        [Invoice date],
        [Invoice Number],
        [Invoice Sequence],
        [Account And Shipto Number],
        [Territory],
        [SalesTerritoryID],
        [Item SKU],
        [item Key],
        [Store Address ID],
        [Shipto AddressID],
        [Warehouse],
        [Item Status],
        [Order Item Status],
        [Quantity Shipped],
        [Invoice Discount],
        [Amount Shipped],
        [Other Allowances],
        [Allocated Freight],
        [Invoiced Line Item Freight],
        [Other Freight],
        [Cubes],
        [Seats],
        [Advertising Accrual],
        [Invoice DFI Discount],
        [Contract Price Amount],
        [Bonded Warehouse Transfer Quantity],
        [Bonded Warehouse Transfer Amount],
        [Order Number],
        [Trip Number],
        [Purchase Order],
        [Order Arrival Mode],
        [Primary Order Type],
        [Secondary Order Type],
        [Order Arrival Group],
        [Order Arrival Electronic],
        [3rd Order Type],
        [4th Order Type],
        [Invoice Credit Code],
        [Order Sequence],
        [Request Date],
        [Promise Date],
        [Delivery Date],
        [Order Date],
        [Delivery Days - Promised],
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
        [AFI Sales Category],
        [Division Code],
        [Sales Region Code],
        [Sales RepID],
        [Marketing Specialist ID],
        [RegionCode_RepID_Category],
        [Account Number],
        [Shipto Number],
        [Customer Shipto Division Number],
        [TruckLoad Trip Type],
        [Customer SKU/Package]
    FROM
        (
            SELECT
                    [Invoice date]                                        = InvoiceDetail.[InvoiceDate],                                                     --Fact invoice
                    [Invoice Number]                                      = InvoiceDetail.[InvoiceNumber],                                                   --Fact invoice
                    [Invoice Sequence]                                    = InvoiceDetail.[ItemSequence],
                    DimCustomers.[Account And Shipto Number],                                                                                                --Fact Invoice
                    CASE
                        WHEN CAST([Shipto Sales Territory] AS INT) = 0
                            THEN
                            [Primary Sales Territory]
                        ELSE
                            [Primary Sales Territory] + [Shipto Sales Territory]
                    END                                                   AS Territory,                                                                      --Fact Invoice
                    [SalesTerritoryID],                                                                                                                      --Fact Invoice
                    [Item SKU]                                            = ISNULL(InvoiceDetail.ItemSKU, ''),                                            --Fact Invoice but it uses dimitemmaster
                    [item Key]                                            = 'ASHLEY_' + ISNULL(InvoiceDetail.ItemSKU, ''),
                    DimCustomers.[Store Address ID],                                                                                                         --Fact Invoice
                    DimCustomers.[Shipto AddressID],                                                                                                         --Fact Invoice
                    [Warehouse]                                           = ISNULL(InvoiceDetail.Warehouse, ''),                                             --Fact Invoice
                    [Item Status]                                         = CASE
                                                                                WHEN InvoiceDetail.[OrderItemStatus] = 'N'
                                                                                    THEN
                                                                                    ''
                                                                                ELSE
                                                                                    InvoiceDetail.[OrderItemStatus]
                                                                            END,                                                                             --Fact Invoice
                    [Order Item Status]                                   = InvoiceDetail.[OrderItemStatus],
                    [Quantity Shipped]                                    = CASE
                                                                                WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                           'R', 'A', 'S'
                                                                                                                       )
                                                                                     AND NOT (
                                                                                                 DimCustomers.[Customer Account Number] = '3824800'
                                                                                                 AND ISNULL(InvoiceDetail.[Warehouse], '') = '335'
                                                                                             )
                                                                                    THEN
                                                                                    CAST(InvoiceDetail.[QuantityShipped]
                                                                                         * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                                                                ELSE
                                                                                    00000.000
                                                                            END,                                                                             --Fact Invoice
                    [Invoice Discount]                                    = CAST((InvoiceDetail.[Discount] * InvoiceDetail.[QuantityShipped])
                                                                                 * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(13, 3)), --Fact Invoice
                    [Amount Shipped]                                      = CAST(CASE
                                                                                     WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                                'R', 'A', 'S'
                                                                                                                            )
                                                                                          AND NOT (
                                                                                                      DimCustomers.[Customer Account Number] = '3824800'
                                                                                                      AND ISNULL(InvoiceDetail.[Warehouse], '') = '335'
                                                                                                  )
                                                                                         THEN
                    (([Price] - [Freight] - [PriceAdjustment] + [Discount]) * [QuantityShipped])
                    * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                                                     ELSE
                                                                                         0000000.000
                                                                                 END AS DECIMAL(9, 3)),                                                      --Fact Invoice
                    [Other Allowances]                                    = 000000.000,                                                                      --Fact Invoice refer third union all
                    [Allocated Freight]                                   = 000000.000,                                                                      --Fact Invoice refer third union all
                    [Invoiced Line Item Freight]                          = CAST((InvoiceDetail.[Freight] * InvoiceDetail.[QuantityShipped])
                                                                                 * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(9, 3)),  --Fact Invoice
                    [Other Freight]                                       = 000000.000,                                                                      --Fact Invoice refer second union all
                    [Cubes]                                               = CASE
                                                                                WHEN InvoiceDetail.[QuantityShipped] > 0
                                                                                    THEN
                                                                                    DimItemMaster.[Cubes] * InvoiceDetail.[QuantityShipped]
                                                                                    * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                                                ELSE
                                                                                    0
                                                                            END,                                                                             --Fact Invoice
                    [Seats]                                               = CASE
                                                                                WHEN InvoiceDetail.[QuantityShipped] > 0
                                                                                    THEN
                                                                                    DimItemMaster.Seats * InvoiceDetail.[QuantityShipped]
                                                                                    * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                                                ELSE
                                                                                    0
                                                                            END,                                                                             --Fact Invoice
                    [Advertising Accrual]                                 = CAST(ISNULL(
                                                                                           (InvoiceDetail.[AdvertisingAccrual]
                                                                                            * InvoiceDetail.[QuantityShipped]
                                                                                           )
                                                                                           * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1), 0
                                                                                       ) AS DECIMAL(9, 3)),                                                  --Fact Invoice
                    [Invoice DFI Discount]                                = CAST(ISNULL(
                                                                                           (InvoiceDetail.[DFIDiscount] * InvoiceDetail.[QuantityShipped])
                                                                                           * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1), 0
                                                                                       ) AS DECIMAL(9, 3)),                                                  --Fact Invoice
                    [Contract Price Amount]                               = CAST(ISNULL(
                                                                                           (InvoiceDetail.[ContractPrice]
                                                                                            * InvoiceDetail.[QuantityShipped]
                                                                                           )
                                                                                           * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1), 0
                                                                                       ) AS DECIMAL(9, 3)),                                                  --Fact Invoice
                    [Bonded Warehouse Transfer Quantity]                  = CASE
                                                                                WHEN DimCustomers.[Customer Account Number] = '3824800'
                                                                                     AND ISNULL(InvoiceDetail.[Warehouse], '') = '335'
                                                                                    THEN
                                                                                    CAST(InvoiceDetail.[QuantityShipped]
                                                                                         * ISNULL(
                                                                                                     TerritoryAllocationStatic.CommissionSplitPercent,
                                                                                                     1
                                                                                                 ) AS DECIMAL(11, 3))
                                                                                ELSE
                                                                                    00000.000
                                                                            END,
                    [Bonded Warehouse Transfer Amount]                    = CASE
                                                                                WHEN DimCustomers.[Customer Account Number] = '3824800'
                                                                                     AND ISNULL(InvoiceDetail.[Warehouse], '') = '335'
                                                                                    THEN
                    (([Price] - [Freight] - [PriceAdjustment] + [Discount]) * [QuantityShipped])
                    * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                                                ELSE
                                                                                    0000000.000
                                                                            END,
                    [Order Number]                                        = InvoiceHeader.[OrderNumber],
                    [Trip Number]                                         = InvoiceHeader.[TripNumber],
                    [Purchase Order]                                      = InvoiceHeader.[PurchaseOrder],
                    [Order Arrival Mode]                                  = OrderArrivalCode.Description,
                    [Primary Order Type]                                  = t1.Description,
                    [Secondary Order Type]                                = t2.Description,
                    [Order Arrival Group]                                 = OrderArrivalGroup.Description,
                    [Order Arrival Electronic]                            = OrderArrivalGroup.Electronic,
                    [3rd Order Type]                                      = t3.Description,
                    [4th Order Type]                                      = t4.Description,
                    [Invoice Credit Code]                                 = InvoiceHeader.[CreditCode],
                    CASE
                        WHEN InvoiceHeader.[Sequence] = 0
                            THEN
                            'Delivery to'
                        ELSE
                            ''
                    END                                                   [Order Sequence],
                    [Request Date]                                        = InvoiceHeader.[RequestDate],
                    [Promise Date]                                        = InvoiceDetail.[PromisedDelivery],
                    [Delivery Date]                                       = CASE
                                                                                WHEN
                                                                                    (
                                                                                        InvoiceDetail.[DeliveryDays] IS NOT NULL
                                                                                        AND InvoiceHeader.[CreditCode] = ''
                                                                                        AND InvoiceHeader.[RequestDate] IS NOT NULL
                                                                                        AND CASE
                                                                                                WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                                           'R', 'A', 'S'
                                                                                                                                       )
                                                                                                    THEN
                                                                                                    CAST(InvoiceDetail.[QuantityShipped]
                                                                                                         * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                                                                                ELSE
                                                                                                    00000.000
                                                                                            END <> 0
                                                                                    )
                                                                                    THEN
                                                                                    InvoiceDetail.[ActualDelivery]
                                                                                ELSE
                                                                                    NULL
                                                                            END,
                    [Order Date]                                          = InvoiceDetail.[OrderEntry],


                                                                                                                                                             --- Add Speed to market measures
                    [Delivery Days - Promised]                            = InvoiceDetail.[DeliveryDaysOriginalPromiseDate],
                    [Speed To Market Base]                                = CASE
                                                                                WHEN
                                                                                    (
                                                                                        InvoiceDetail.[DeliveryDays] IS NOT NULL
                                                                                        AND InvoiceHeader.[CreditCode] = ''
                                                                                        AND InvoiceHeader.[RequestDate] IS NOT NULL
                                                                                        AND CASE
                                                                                                WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                                           'R', 'A', 'S'
                                                                                                                                       )
                                                                                                    THEN
                                                                                                    CAST(InvoiceDetail.[QuantityShipped]
                                                                                                         * ISNULL(
                                                                                                                     TerritoryAllocationStatic.CommissionSplitPercent,
                                                                                                                     1
                                                                                                                 ) AS DECIMAL(11, 3))
                                                                                                ELSE
                                                                                                    00000.000
                                                                                            END <> 0
                                                                                    )
                                                                                    THEN
                                                                                    DATEDIFF(DD, InvoiceHeader.[RequestDate], InvoiceHeader.[InvoiceDate])
                                                                                ELSE
                                                                                    DATEDIFF(DD, InvoiceHeader.[RequestDate], InvoiceDetail.[ActualDelivery])
                                                                            END,
                    [Speed to Market]                                     = CASE
                                                                                WHEN
                                                                                    (
                                                                                        InvoiceDetail.[DeliveryDays] IS NOT NULL
                                                                                        AND InvoiceHeader.[CreditCode] = ''
                                                                                        AND InvoiceHeader.[RequestDate] IS NOT NULL
                                                                                        AND CASE
                                                                                                WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                                           'R', 'A', 'S'
                                                                                                                                       )
                                                                                                    THEN
                                                                                                    CAST(InvoiceDetail.[QuantityShipped]
                                                                                                         * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                                                                                ELSE
                                                                                                    00000.000
                                                                                            END <> 0
                                                                                    )
                                                                                    THEN
                                                                                    InvoiceDetail.[DeliveryDays]
                                                                                ELSE
                                                                                    0
                                                                            END,
                    [Delivery Days]                                       = CASE
                                                                                WHEN
                                                                                    (
                                                                                        InvoiceDetail.[DeliveryDays] IS NOT NULL
                                                                                        AND InvoiceHeader.[CreditCode] = ''
                                                                                        AND InvoiceHeader.[RequestDate] IS NOT NULL
                                                                                        AND CASE
                                                                                                WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                                           'R', 'A', 'S'
                                                                                                                                       )
                                                                                                    THEN
                                                                                                    CAST(InvoiceDetail.[QuantityShipped]
                                                                                                         * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                                                                                ELSE
                                                                                                    00000.000
                                                                                            END <> 0
                                                                                    )
                                                                                    THEN
                                                                                    InvoiceDetail.[DeliveryDays]
                                                                                ELSE
                                                                                    0
                                                                            END,
                        -- BH changed 5/22/2018  (removed null delivery dates from denominator since it doesn't show up in any of the numberator aggrigates)
                       --CASE WHEN DeliveryDays IS NULL THEN 0 ELSE QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) END  AS [Stm Base Calc]
                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [Stm Base Calc],

                       --CASE WHEN DeliveryDays IS NULL THEN 0 ELSE 1 * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1)  END AS [Stm Count] 
                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            1 * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [Stm Count],


                      --CASE WHEN DeliveryDays < 0 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [Early]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] < 0
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [Early],


                    --CASE WHEN DeliveryDays = 0 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [On Time]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 0
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [On Time],



                     --CASE WHEN DeliveryDays = 1 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [1 Day Late]
                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 1
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [1 Day Late],
                      
                       --CASE WHEN DeliveryDays = 2 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [2 Days Late]
                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 2
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [2 Days Late],



                     --CASE WHEN DeliveryDays = 3 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [3 Days Late]
                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 3
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [3 Days Late],



                   --CASE WHEN DeliveryDays = 4 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [4 Days Late]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 4
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [4 Days Late],


                    --CASE WHEN DeliveryDays = 5 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [5 Days Late]
                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 5
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [5 Days Late],



                       --CASE WHEN DeliveryDays = 6 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [6 Days Late]
                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 6
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [6 Days Late],




                     --CASE WHEN DeliveryDays = 7 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [7 Days Late]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] = 7
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [7 Days Late],
                 --CASE WHEN DeliveryDays BETWEEN 8 AND 14 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [8 to 14 Days Late]


                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays]
                            BETWEEN 8 AND 14
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [8 to 14 Days Late],


                       --CASE WHEN DeliveryDays BETWEEN 15 AND 21 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [15 to 21 Days Late]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays]
                            BETWEEN 15 AND 21
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [15 to 21 Days Late],

                    --CASE WHEN DeliveryDays BETWEEN 22 AND 28 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [22 to 28 Days Late]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays]
                            BETWEEN 22 AND 28
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [22 to 28 Days Late],

                       --CASE WHEN DeliveryDays > 28 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [Over 28 Days Late]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDays] > 28
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [Over 28 Days Late],

                        ---CASE WHEN DeliveryDays_OrigProm < 0 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [Early - Promised]


                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] < 0
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [Early - Promised],



                     --CASE WHEN DeliveryDays_OrigProm = 0 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [On Time - Promised]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 0
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [On Time - Promised],

                     --CASE WHEN DeliveryDays_OrigProm = 1 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [1 Day Late - Promised]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 1
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST([QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [1 Day Late - Promised],


                     --CASE WHEN DeliveryDays_OrigProm = 2 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [2 Days Late - Promised]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 2
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [2 Days Late - Promised],


                      --CASE WHEN DeliveryDays_OrigProm = 3 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [3 Days Late - Promised]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 3
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [3 Days Late - Promised],






                        --CASE WHEN DeliveryDays_OrigProm = 4 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [4 Days Late - Promised]


                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 4
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [4 Days Late - Promised],




                       --CASE WHEN DeliveryDays_OrigProm = 5 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [5 Days Late - Promised]


                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 5
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [5 Days Late - Promised],





                       --CASE WHEN DeliveryDays_OrigProm = 6 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [6 Days Late - Promised]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 6
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST([QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [6 Days Late - Promised],



                      --CASE WHEN DeliveryDays_OrigProm = 7 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [7 Days Late - Promised]


                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] = 7
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(11, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [7 Days Late - Promised],



                       --CASE WHEN DeliveryDays_OrigProm BETWEEN 8 AND 14 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [8 to 14 Days Late - Promised]

                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate]
                            BETWEEN 8 AND 14
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(7, 2))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [8 to 14 Days Late - Promised],



                      --CASE WHEN DeliveryDays_OrigProm BETWEEN 15 AND 21 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [15 to 21 Days Late - Promised]

                    CASE
                        WHEN
                            (
                                [DeliveryDaysOriginalPromiseDate]
                            BETWEEN 15 AND 21
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(7, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [15 to 21 Days Late - Promised],





                      --CASE WHEN DeliveryDays_OrigProm BETWEEN 22 AND 28 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [22 to 28 Days Late - Promised]


                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate]
                            BETWEEN 22 AND 28
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(7, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [22 to 28 Days Late - Promised],


                    --CASE WHEN DeliveryDays_OrigProm > 28 THEN QuantityShipped * isnull(TerritoryAllocationStatic.CommissionSplitPercent,1) ELSE 0 END AS [Over 28 Days Late - Promised]


                    CASE
                        WHEN
                            (
                                InvoiceDetail.[DeliveryDaysOriginalPromiseDate] > 28
                                AND InvoiceDetail.[DeliveryDays] IS NOT NULL
                                AND InvoiceHeader.[CreditCode] = ''
                                AND InvoiceHeader.[RequestDate] IS NOT NULL
                                AND CASE
                                        WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                   'R', 'A', 'S'
                                                                               )
                                            THEN
                                            CAST(InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(7, 3))
                                        ELSE
                                            00000.000
                                    END <> 0
                            )
                            THEN
                            InvoiceDetail.[QuantityShipped] * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                        ELSE
                            0
                    END                                                   AS [Over 28 Days Late - Promised],
                    DimSalesTerritories.[AFI Sales Category],                                                                                                --Newly added for Fact Invoice
                    DimItemMaster.[AFISalesDivisionCode]                  AS [Division Code],                                                                --Newly added for Fact Invoice
                    DimSalesTerritories.[AFI Sales Region Code]           AS [Sales Region Code],                                                            --Newly added for Fact Invoice
                    DimSalesTerritories.[AFI Sales RepID]                 AS [Sales RepID],                                                                  --Newly added for Fact Invoice
                    DimSalesTerritories.[Marketing Specialist ID],
                    DimSalesTerritories.RegionCode_RepID_Category,                                                                                           --Newly added for Fact Invoice
                    DimCustomers.[Customer Account Number]                AS [Account Number],                                                               --Newly added for Fact Invoice
                    DimCustomers.[Customer Shipto Number]                 AS [Shipto Number],                                                                --Newly added for Fact Invoice
                    RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number])
                    + '-' + DimSalesTerritories.[AFI Sales Division Code] AS [Customer Shipto Division Number],                                              --Newly added for Fact Invoice
                    Truckloads.TripType                                   AS [TruckLoad Trip Type],
                    CASE
                        WHEN InvoiceDetail.PackageID <> ''
                            THEN
                            InvoiceDetail.PackageID
                        ELSE
                            COALESCE(PackageComments.PackageSKU, InvoiceDetail.ItemSKU)
                    END                                                   AS [Customer SKU/Package]
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                JOIN
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceHeader
                        ON InvoiceHeader.[InvoiceNumber] = InvoiceDetail.[InvoiceNumber]
                           AND InvoiceDetail.[InvoiceDate] = InvoiceHeader.[InvoiceDate]
                JOIN
                    AFISales_DW.DimCustomers                   
                        ON [Customer Account Number] = InvoiceHeader.[CustomerNumber]
                           AND [Customer Shipto Number] = InvoiceHeader.[ShiptoNumber]
                JOIN
                    AFISales_DW.DimItemMaster                
                        ON DimItemMaster.ItemSKU = InvoiceDetail.ItemSKU
                LEFT JOIN
                    [$(Distribution_Warehouse)].Transportation.Truckloads Truckloads
                        ON Truckloads.TripNumber = InvoiceHeader.[TripNumber]
                           AND CONVERT(DATE, CONVERT(VARCHAR(10), Truckloads.CreatedDate), 111) = InvoiceHeader.[RequestDate]
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
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderArrivalCode
                        ON InvoiceHeader.[OrderArrivalCode] = OrderArrivalCode.OrderArrivalCode
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderArrivalGroup
                        ON OrderArrivalCode.ModeGroup = OrderArrivalGroup.[Group]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t1
                        ON t1.OrderTypeCode = [OrderTypePrimary]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t2
                        ON t2.OrderTypeCode = [OrderTypeSecondary]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t3
                        ON t3.OrderTypeCode = [OrderTypeUsrDefine3]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t4
                        ON t4.OrderTypeCode = [OrderTypeUsrDefine4]
                LEFT JOIN
                    PackageComments
                        ON InvoiceDetail.InvoiceNumber = PackageComments.InvoiceNumber
                           AND InvoiceDetail.ItemSequence = PackageComments.ItemSequence
                           AND InvoiceDetail.InvoiceDate = PackageComments.InvoiceDate
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
                                                                                    DimItemMaster.AFISalesCategoryCode,
                                                                                    CAST('ZZ' AS CHAR(3))
                                                                                )
                           AND DimSalesTerritories.[Active Record] = 1
            WHERE
                    [ExtendedInvoiceNumber] <> '0'
                    AND [QuantityShipped] <> 0 

            UNION ALL
            SELECT
                    InvoiceHeader.[InvoiceDate],
                    InvoiceHeader.[InvoiceNumber],
                    '100'                                                 AS ItemSequence,
                    DimCustomers.[Account And Shipto Number],
                    CASE
                        WHEN CAST([Shipto Sales Territory] AS INT) = 0
                            THEN
                            [Primary Sales Territory]
                        ELSE
                            [Primary Sales Territory] + [Shipto Sales Territory]
                    END                                                   AS Territory,
                    [SalesTerritoryID],
                    'N/A',
                    'ASHLEY_N/A',
                    DimCustomers.[Store Address ID],
                    DimCustomers.[Shipto AddressID],
                    SpecialCharges.[Warehouse],
                    'Z',
                    'Z',
                    0,
                    0,
                    0,
                    CASE
                        WHEN ISNULL([Code], 0) <> '1'
                            THEN
                            [Amount]
                        ELSE
                            0
                    END,
                    0,
                    0,
                    CASE
                        WHEN ISNULL([Code], 0) = '1'
                            THEN
                            [Amount]
                        ELSE
                            0
                    END,                                                                                        --fact invoice
                    0,
                    0,
                    [Advertising Accrual]                                 = 00000000.00,
                    [Invoice DFI Discount]                                = 00000000.00,
                    [Contract Price Amount]                               = 00000000.00,
                    [Bonded Warehouse Transfer Quantity]                  = 0,
                    [Bonded Warehouse Transfer Amount]                    = 0,
                    [Order Number]                                        = InvoiceHeader.[OrderNumber],
                    [Trip Number]                                         = InvoiceHeader.[TripNumber],
                    [Purchase Order]                                      = InvoiceHeader.[PurchaseOrder],
                    [Order Arrival Mode]                                  = OrderArrivalCode.Description,
                    [Primary Order Type]                                  = t1.Description,
                    [Secondary Order Type]                                = t2.Description,
                    [Order Arrival Group]                                 = OrderArrivalGroup.Description,
                    [Order Arrival Electronic]                            = OrderArrivalGroup.Electronic,
                    [3rd Order Type]                                      = t3.Description,
                    [4th Order Type]                                      = t4.Description,
                    [Invoice Credit Code]                                 = InvoiceHeader.[CreditCode],
                    CASE
                        WHEN InvoiceHeader.[Sequence] = 0
                            THEN
                            'Delivery to'
                        ELSE
                            ''
                    END                                                   [Order Sequence],
                    [Request Date]                                        = NULL,
                    [Promise Date]                                        = NULL,
                    [Delivery Date]                                       = NULL,
                    [Order Date]                                          = CAST(InvoiceHeader.[OrderDate] AS DATE),
                                                                                                                --- Add Speed to market measures
                    [Delivery Days - Promised]                            = 0,
                    [Speed To Market Base]                                = 0,
                    [Speed to Market]                                     = 0,
                    [Delivery Days]                                       = 0,
                    [Stm Base Calc]                                       = 0,
                    [Stm Count]                                           = 0,
                    [Early]                                               = 0,
                    [On Time]                                             = 0,
                    [1 Day Late]                                          = 0,
                    [2 Days Late]                                         = 0,
                    [3 Days Late]                                         = 0,
                    [4 Days Late]                                         = 0,
                    [5 Days Late]                                         = 0,
                    [6 Days Late]                                         = 0,
                    [7 Days Late]                                         = 0,
                    [8 to 14 Days Late]                                   = 0,
                    [15 to 21 Days Late]                                  = 0,
                    [22 to 28 Days Late]                                  = 0,
                    [Over 28 Days Late]                                   = 0,
                    [Early - Promised]                                    = 0,
                    [On Time - Promised]                                  = 0,
                    [1 Day Late - Promised]                               = 0,
                    [2 Days Late - Promised]                              = 0,
                    [3 Days Late - Promised]                              = 0,
                    [4 Days Late - Promised]                              = 0,
                    [5 Days Late - Promised]                              = 0,
                    [6 Days Late - Promised]                              = 0,
                    [7 Days Late - Promised]                              = 0,
                    [8 to 14 Days Late - Promised]                        = 0,
                    [15 to 21 Days Late - Promised]                       = 0,
                    [22 to 28 Days Late - Promised]                       = 0,
                    [Over 28 Days Late - Promised]                        = 0,
                    DimSalesTerritories.[AFI Sales Category],                                                   --Newly added for Fact Invoice
                    'Z',                                                                                        --Newly added for Fact Invoice
                    DimSalesTerritories.[AFI Sales Region Code]           AS [Sales Region Code],               --Newly added for Fact Invoice
                    DimSalesTerritories.[AFI Sales RepID]                 AS [Sales RepID],                     --Newly added for Fact Invoice
                    DimSalesTerritories.[Marketing Specialist ID],
                    DimSalesTerritories.RegionCode_RepID_Category,                                              --Newly added for Fact Invoice
                    DimCustomers.[Customer Account Number]                AS [Account Number],                  --Newly added for Fact Invoice
                    DimCustomers.[Customer Shipto Number]                 AS [Shipto Number],                   --Newly added for Fact Invoice
                    RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number])
                    + '-' + DimSalesTerritories.[AFI Sales Division Code] AS [Customer Shipto Division Number], --Newly added for Fact Invoice
                    Truckloads.TripType,
                    'N/A'                                                 AS [Customer SKU/Package]
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.SpecialCharges
                JOIN
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceHeader
                        ON SpecialCharges.[InvoiceNumber] = InvoiceHeader.[InvoiceNumber]
                           AND SpecialCharges.[InvoiceDate] = InvoiceHeader.[InvoiceDate]
                JOIN
                    AFISales_DW.DimCustomers
                        ON [Customer Account Number] = InvoiceHeader.[CustomerNumber]
                           AND [Customer Shipto Number] = InvoiceHeader.[ShiptoNumber]
                LEFT JOIN
                    [$(Distribution_Warehouse)].Transportation.Truckloads Truckloads
                        ON Truckloads.TripNumber = InvoiceHeader.[TripNumber] 
                           AND CONVERT(DATE, CONVERT(VARCHAR(10), Truckloads.CreatedDate), 111) = CAST([RequestDate] AS DATE)
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.CreditCodes
                        ON InvoiceHeader.[CreditCode] = CreditCodes.CreditCode
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderArrivalCode
                        ON InvoiceHeader.[OrderArrivalCode] = OrderArrivalCode.OrderArrivalCode
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderArrivalGroup
                        ON OrderArrivalCode.ModeGroup = OrderArrivalGroup.[Group]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode t1
                        ON t1.OrderTypeCode = [OrderTypePrimary]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode t2
                        ON t2.OrderTypeCode = [OrderTypeSecondary]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode t3
                        ON t3.OrderTypeCode = [OrderTypeUsrDefine3]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode t4
                        ON t4.OrderTypeCode = [OrderTypeUsrDefine4]
                LEFT JOIN
                    AFISales_DW.DimSalesTerritories       
                        ON DimSalesTerritories.[AFI Sales Region Code] = CAST('Z' AS CHAR(3))
                           AND DimSalesTerritories.[AFI Sales RepID] = CAST('ZZZZZ' AS CHAR(5))
                           AND DimSalesTerritories.[AFI Sales Category] = CAST('ZZ' AS CHAR(3))
                           AND DimSalesTerritories.[Active Record] = 1

            --WHERE Crdid <> 'Q' --and schDtrndt <= DW_Developer.fn_GetCSTDate(GETDATE())

            UNION ALL
            --- Add Commission Adjument logic from ShippedHistoryCOmmAdjust
            SELECT
                    [Invoice date]                                        = InvoiceDetail.[InvoiceDate],
                    [Invoice Number]                                      = InvoiceDetail.[InvoiceNumber],
                    InvoiceDetail.[ItemSequence],
                    DimCustomers.[Account And Shipto Number],
                    CASE
                        WHEN CAST([Shipto Sales Territory] AS INT) = 0
                            THEN
                            [Primary Sales Territory]
                        ELSE
                            [Primary Sales Territory] + [Shipto Sales Territory]
                    END                                                   AS Territory,
                    [SalesTerritoryID],
                    [Item SKU]                                            = ISNULL(InvoiceDetail.ItemSKU, ''),
                    [Item Key]                                            = 'ASHLEY_' + ISNULL(InvoiceDetail.ItemSKU, ''),
                    DimCustomers.[Store Address ID],
                    DimCustomers.[Shipto AddressID],
                    [Warehouse]                                           = ISNULL(InvoiceDetail.[Warehouse], ''),
                    [Item Status]                                         = CASE
                                                                                WHEN InvoiceDetail.[OrderItemStatus] = 'N'
                                                                                    THEN
                                                                                    ''
                                                                                ELSE
                                                                                    InvoiceDetail.[OrderItemStatus]
                                                                            END,
                    [Order Item Status]                                   = InvoiceDetail.[OrderItemStatus],
                    [Quantity Shipped]                                    = 00000000.00,
                    [Invoice Discount]                                    = 00000000.00,
                    [Amount Shipped]                                      = CASE
                                                                                WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                           'R', 'A', 'S'
                                                                                                                       )
                                                                                    THEN
                                                                                    CAST(CASE
                                                                                             WHEN ISNULL(CreditCodes.AllocationCode, '') = 'GROSS'
                                                                                                 THEN
                    (ShippedHistoryCommAdjustment.[ExceptionAmount] * InvoiceDetail.[QuantityShipped]) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                                                             ELSE
                                                                                                 0
                                                                                         END AS DECIMAL(12,2))
                                                                                ELSE
                                                                                    0000000.000
                                                                            END,
                    [Other Allowances]                                    = CAST(CASE
                                                                                     WHEN ISNULL(CreditCodes.AllocationCode, '') NOT IN (
                                                                                                                                   'GROSS', 'FREIGHT'
                                                                                                                               )
                                                                                         THEN
                    (ShippedHistoryCommAdjustment.[ExceptionAmount] * InvoiceDetail.[QuantityShipped]) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                                                     ELSE
                                                                                         0
                                                                                 END AS DECIMAL(12,2)),                 --Fact Invoice
                    [Allocated Freight]                                   = CAST(CASE
                                                                                     WHEN ISNULL(CreditCodes.AllocationCode, '') = 'FREIGHT'
                                                                                         THEN
                    (ShippedHistoryCommAdjustment.[ExceptionAmount] * InvoiceDetail.[QuantityShipped]) * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1)
                                                                                     ELSE
                                                                                         0
                                                                                 END AS DECIMAL(12,2)),                 --Fact Invoice
                    [Invoiced Line Item Freight]                          = 000000.00,
                    [Other Freight]                                       = 000000000.00,
                    [Cubes]                                               = 0,
                    [Seats]                                               = 0,
                    [Advertising Accrual]                                 = 00000000.00,
                    [Invoice DFI Discount]                                = 00000000.00,
                    [Contract Price Amount]                               = 00000000.00,
                    [Bonded Warehouse Transfer Quantity]                  = 0,
                    [Bonded Warehouse Transfer Amount]                    = 0,
                    [Order Number]                                        = InvoiceHeader.[OrderNumber],
                    [Trip Number]                                         = InvoiceHeader.[TripNumber],
                    [Purchase Order]                                      = InvoiceHeader.[PurchaseOrder],
                    [Order Arrival Mode]                                  = OrderArrivalCode.Description,
                    [Primary Order Type]                                  = t1.Description,
                    [Secondary Order Type]                                = t2.Description,
                    [Order Arrival Group]                                 = OrderArrivalGroup.Description,
                    [Order Arrival Electronic]                            = OrderArrivalGroup.Electronic,
                    [3rd Order Type]                                      = t3.Description,
                    [4th Order Type]                                      = t4.Description,
                    [Invoice Credit Code]                                 = InvoiceHeader.[CreditCode],
                    CASE
                        WHEN InvoiceHeader.[Sequence] = 0
                            THEN
                            'Delivery to'
                    END                                                   [Order Sequence],
                    [Request Date]                                        = InvoiceHeader.[RequestDate],
                    [Promise Date]                                        = CAST([PromisedDelivery] AS DATE),
                    [Delivery Date]                                       = CASE
                                                                                WHEN
                                                                                    (
                                                                                        [DeliveryDays] IS NOT NULL
                                                                                        AND InvoiceHeader.[CreditCode] = ''
                                                                                        AND InvoiceHeader.[RequestDate] IS NOT NULL
                                                                                        AND CASE
                                                                                                WHEN InvoiceDetail.[CreditCode] NOT IN (
                                                                                                                                           'R', 'A', 'S'
                                                                                                                                       )
                                                                                                    THEN
                                                                                                    CAST([QuantityShipped]
                                                                                                         * ISNULL(TerritoryAllocationStatic.CommissionSplitPercent, 1) AS DECIMAL(7, 3))
                                                                                                ELSE
                                                                                                    00000.000
                                                                                            END <> 0
                                                                                    )
                                                                                    THEN
                                                                                    CAST([ActualDelivery] AS DATE)
                                                                                ELSE
                                                                                    NULL
                                                                            END,
                    [Order Date]                                          = CAST(InvoiceHeader.[OrderDate] AS DATE),


                                                                                                                --- Add Speed to market measures
                    [Delivery Days - Promised]                            = 0,
                    [Speed To Market Base]                                = 0,
                    [Speed to Market]                                     = 0,
                    [Delivery Days]                                       = 0,
                    [Stm Base Calc]                                       = 0,
                    [Stm Count]                                           = 0,
                    [Early]                                               = 0,
                    [On Time]                                             = 0,
                    [1 Day Late]                                          = 0,
                    [2 Days Late]                                         = 0,
                    [3 Days Late]                                         = 0,
                    [4 Days Late]                                         = 0,
                    [5 Days Late]                                         = 0,
                    [6 Days Late]                                         = 0,
                    [7 Days Late]                                         = 0,
                    [8 to 14 Days Late]                                   = 0,
                    [15 to 21 Days Late]                                  = 0,
                    [22 to 28 Days Late]                                  = 0,
                    [Over 28 Days Late]                                   = 0,
                    [Early - Promised]                                    = 0,
                    [On Time - Promised]                                  = 0,
                    [1 Day Late - Promised]                               = 0,
                    [2 Days Late - Promised]                              = 0,
                    [3 Days Late - Promised]                              = 0,
                    [4 Days Late - Promised]                              = 0,
                    [5 Days Late - Promised]                              = 0,
                    [6 Days Late - Promised]                              = 0,
                    [7 Days Late - Promised]                              = 0,
                    [8 to 14 Days Late - Promised]                        = 0,
                    [15 to 21 Days Late - Promised]                       = 0,
                    [22 to 28 Days Late - Promised]                       = 0,
                    [Over 28 Days Late - Promised]                        = 0,
                    DimSalesTerritories.[AFI Sales Category],                                                   --Newly added for Fact Invoice
                    DimItemMaster.[AFISalesDivisionCode]                             AS [Division Code],                   --Newly added for Fact Invoice
                    DimSalesTerritories.[AFI Sales Region Code]           AS [Sales Region Code],               --Newly added for Fact Invoice
                    DimSalesTerritories.[AFI Sales RepID]                 AS [Sales RepID],                     --Newly added for Fact Invoice
                    DimSalesTerritories.[Marketing Specialist ID],
                    DimSalesTerritories.RegionCode_RepID_Category,                                              --Newly added for Fact Invoice
                    DimCustomers.[Customer Account Number]                AS [Account Number],                  --Newly added for Fact Invoice
                    DimCustomers.[Customer Shipto Number]                 AS [Shipto Number],                   --Newly added for Fact Invoice
                    RTRIM(DimCustomers.[Customer Account Number]) + '-' + RTRIM(DimCustomers.[Customer Shipto Number])
                    + '-' + DimSalesTerritories.[AFI Sales Division Code] AS [Customer Shipto Division Number], --Newly added for Fact Invoice
                    Truckloads.TripType AS TripType,
                    CASE
                        WHEN InvoiceDetail.PackageID <> ''
                            THEN
                            InvoiceDetail.PackageID
                        ELSE
                            COALESCE(PackageComments.PackageSKU, InvoiceDetail.ItemSKU)
                    END                                                   AS [Customer SKU/Package]
            FROM
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.ShippedHistoryCommAdjustment
                JOIN
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceDetail
                        ON InvoiceDetail.[InvoiceNumber] = ShippedHistoryCommAdjustment.[InvoiceNumber]
                           AND InvoiceDetail.[OrderNumber] = ShippedHistoryCommAdjustment.[OrderNumber]
                           AND InvoiceDetail.[ItemSKU] = ShippedHistoryCommAdjustment.ItemSKU
                           AND InvoiceDetail.[ItemSequence] = ShippedHistoryCommAdjustment.[ItemSequence]
                JOIN
                    [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceHeader
                        ON InvoiceHeader.[InvoiceNumber] = InvoiceDetail.[InvoiceNumber]
                           AND InvoiceDetail.[InvoiceDate] = InvoiceHeader.[InvoiceDate]
                LEFT JOIN
                    [$(Distribution_Warehouse)].Transportation.Truckloads  Truckloads
                        ON Truckloads.TripNumber = InvoiceHeader.TripNumber
                           AND CONVERT(DATE, CONVERT(VARCHAR(10), Truckloads.CreatedDate), 111) = InvoiceHeader.[RequestDate]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.CreditCodes
                        ON CreditCodes.CreditCode = [CommissionAdjustmentCode]
                JOIN
                    AFISales_DW.DimCustomers                   
                        ON [Customer Account Number] = InvoiceDetail.[CustomerNumber]
                           AND [Customer Shipto Number] = InvoiceDetail.[ShiptoNumber]
                JOIN
                    AFISales_DW.DimItemMaster                
                        ON DimItemMaster.ItemSKU = InvoiceDetail.ItemSKU
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
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderArrivalCode
                        ON InvoiceHeader.OrderArrivalCode = OrderArrivalCode.OrderArrivalCode
                LEFT JOIN 
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderArrivalGroup
                        ON OrderArrivalCode.ModeGroup = OrderArrivalGroup.[Group]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t1
                        ON t1.OrderTypeCode = [OrderTypePrimary]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t2
                        ON t2.OrderTypeCode = [OrderTypeSecondary]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t3
                        ON t3.OrderTypeCode = [OrderTypeUsrDefine3]
                LEFT JOIN
                    [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode      t4
                        ON t4.OrderTypeCode = [OrderTypeUsrDefine4]
                LEFT JOIN
                    PackageComments
                        ON InvoiceDetail.InvoiceNumber = PackageComments.InvoiceNumber
                           AND InvoiceDetail.ItemSequence = PackageComments.ItemSequence
                           AND InvoiceDetail.InvoiceDate = PackageComments.InvoiceDate
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
                                                                                    DimItemMaster.AFISalesCategoryCode,
                                                                                    CAST('ZZ' AS CHAR(3))
                                                                                )
                           AND DimSalesTerritories.[Active Record] = 1
            WHERE
                    [QuantityShipped] <> 0
                    AND [ExtendedInvoiceNumber] <> '0'
        ) Dataset;
