CREATE VIEW [AFISales_DW_Wrk].[v_FactOrderHistory_AcctOwnership]
AS
    SELECT
            ROW_NUMBER() OVER (ORDER BY
                                   OrderHistory.[OrderNumber]
                              )               AS RowID,
            [Order Change Date]               = CAST(OrderHistory.[OrderChangeDate] AS DATE),
            [Order Number]                    = OrderHistory.[OrderNumber],
            [Order Sequence]                  = OrderHistory.[ItemSequence],
            DimCustomers.[Account And Shipto Number],
            CASE
                WHEN CAST(DimCustomers.[Shipto Sales Territory] AS INT) = 0
                    THEN
                    DimCustomers.[Primary Sales Territory]
                ELSE
                    DimCustomers.[Primary Sales Territory] + DimCustomers.[Shipto Sales Territory]
            END                               AS Territory,
            [Item SKU]                        = OrderHistory.[ItemSKU],
            [item Key]                        = 'ASHLEY_' + OrderHistory.[ItemSKU],
            DimCustomers.[Store Address ID],
            DimCustomers.[Shipto AddressID],
            [SalesTerritoryID],
            '-1'                     AS       [Goal ID],
            [Week End Date]                   = CAST(DimDateFile.[Fiscal Week Ended] AS DATE),
            [Warehouse]                       = ISNULL(OrderHistory.[Warehouse], ''),
            [Item Status]                     = ISNULL(OrderHistory.ItemStatus, 'Z'),
            [Amount Cancelled]                = -1.00
                                                * CAST((CASE
                                                            WHEN OrderHistory.[Quantity] < 0
                                                                 AND ISNULL(OrderCancellationReasonCode.CancelCategory, 'SYSTEMIC') <> 'SYSTEMIC'
                                                                THEN
            ([NetAmount] - (OrderHistory.[Quantity] * OrderHistory.Freight)
             - (OrderHistory.[Quantity] * OrderHistory.HiddenFreight) + (OrderHistory.[Quantity] * OrderHistory.Discount)
            )
                                                            ELSE
                                                                0
                                                        END
                                                       ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(13, 3)),
            [Quantity Ordered]                = CAST((OrderHistory.[Quantity]
                                                      * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1)
                                                     ) AS DECIMAL(13, 3)),
            [Amount Ordered]                  = CAST((OrderHistory.[NetAmount] - (OrderHistory.[Quantity] * OrderHistory.Freight)
                                                      - (OrderHistory.[Quantity] * OrderHistory.HiddenFreight)
                                                      + (OrderHistory.[Quantity] * OrderHistory.Discount)
                                                     )
                                                     * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(13, 3)),
            [Order Freight]                   = CAST(OrderHistory.Freight * OrderHistory.[Quantity]
                                                     * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(13, 3)),
            [Total Freight]                   = CAST(((OrderHistory.Freight * OrderHistory.[Quantity])
                                                      + (OrderHistory.HiddenFreight * OrderHistory.[Quantity])
                                                     )
                                                     * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(13, 3)),
            [Allocated Order Freight]         = CAST((OrderHistory.HiddenFreight * OrderHistory.[Quantity])
                                                     * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(13, 3)),
            [Order Discounts]                 = CAST((OrderHistory.[Quantity] * OrderHistory.Discount)
                                                     * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(13, 3)),
            [Request Date]                    = OrderHistory.[RequestDate],
            [Order Date]                      = OrderHistory.[OrderDate],
            [Order Arrival Mode]              = OrderHistory.[OrderArrivalMode],
            [Primary Order Type]              = TYP1.Description,
            [Secondary Order Type]            = TYP2.Description,
            [3rd Order Type]                  = TYP3.Description,
            [4th Order Type]                  = TYP4.Description,
            DimCustomers.[Customer Account Number],
            DimCustomers.[Customer Shipto Number],
            DimSalesTerritories.[AFI Sales Division Code],
            DimSalesTerritories.[AFI Sales Region Code],
            DimSalesTerritories.[AFI Sales RepID],
            DimSalesTerritories.RegionCode_RepID_Category,
            DimSalesTerritories.[AFI Sales Category],
            [Quantity Cancelled]              = -1.00
                                                * CAST((CASE
                                                            WHEN [Quantity] < 0
                                                                 AND ISNULL(OrderCancellationReasonCode.CancelCategory, 'SYSTEMIC') <> 'SYSTEMIC'
                                                                THEN
                                                                OrderHistory.[Quantity]
                                                            ELSE
                                                                0
                                                        END
                                                       ) * ISNULL(MrktSpclstAcctOwnershipSlsCat.Ratio, 1) AS DECIMAL(13, 3)),
            [Reason Code]                     = ISNULL(
                                                          OrderCancellationReasonCode.ReasonCode + ' - '
                                                          + OrderCancellationReasonCode.ReasonDescription, 'N/A'
                                                      ),
            [Customer Shipto Division Number] = CASE
                                                    WHEN DimCustomers.[Customer Shipto Number] = ''
                                                        THEN
                                                        RTRIM(DimCustomers.[Account And Shipto Number]) + '-'
                                                    ELSE
                                                        RTRIM(DimCustomers.[Account And Shipto Number])
                                                END + '-' + DimSalesTerritories.[AFI Sales Division Code]
    FROM
            [$(Wholesale_Warehouse)].SalesHistory_AFI.OrderHistory
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderCancellationReasonCode
                ON OrderCancellationReasonCode.ReasonCode = OrderHistory.ReasonCode
        JOIN
            AFISales_DW.DimCustomers
                ON DimCustomers.[Customer Account Number] = OrderHistory.[CustomerNumber]
                   AND DimCustomers.[Customer Shipto Number] = OrderHistory.[ShiptoNumber]
        LEFT JOIN
            AFISales_DW.DimItemMaster
                ON OrderHistory.ItemSKU = DimItemMaster.ItemSKU
        JOIN
            AFISales_DW.DimDateFile
                ON OrderHistory.[OrderChangeDate] = DimDateFile.[Transaction Date]
        LEFT JOIN
            AFISales_Enh.MrktSpclstAcctOwnershipSlsCat
                ON DimItemMaster.AFISalesDivisionCode = MrktSpclstAcctOwnershipSlsCat.Division
                   AND OrderHistory.[CustomerNumber] = MrktSpclstAcctOwnershipSlsCat.CustomerNumber
                   AND CASE
                           WHEN DimCustomers.[Account Exception Flag] = 0
                               THEN
                               ''
                           WHEN DimCustomers.[Account Exception Flag] = 1
                               THEN
                               OrderHistory.[ShiptoNumber]
                           ELSE
                               ''
                       END = MrktSpclstAcctOwnershipSlsCat.ShiptoNumber
                   AND DimItemMaster.AFISalesCategoryCode = MrktSpclstAcctOwnershipSlsCat.SalesCategory
        LEFT JOIN
            AFISales_DW.[DimSalesTerritories]     
                ON DimSalesTerritories.[AFI Sales Region Code] = ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, CAST('Z' AS CHAR(3)))
                   AND DimSalesTerritories.[AFI Sales RepID] = ISNULL(MrktSpclstAcctOwnershipSlsCat.RepID, CAST('ZZZZZ' AS CHAR(5)))
                   AND DimSalesTerritories.[AFI Sales Category] = CASE
                                                     WHEN ISNULL(DimItemMaster.AFISalesCategoryCode, '') = ''
                                                          OR ISNULL(MrktSpclstAcctOwnershipSlsCat.Region, '') = ''
                                                         THEN
                                                         CAST('ZZ' AS CHAR(3))
                                                     ELSE
                                                         DimItemMaster.AFISalesCategoryCode
                                                 END
                   AND DimSalesTerritories.[Active Record] = 1
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode TYP1
                ON TYP1.OrderTypeCode = OrderTypePrimary
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode TYP2
                ON TYP2.OrderTypeCode = OrderType2
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode TYP3
                ON TYP3.OrderTypeCode = OrderType3
        LEFT JOIN
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.OrderTypeCode TYP4
                ON TYP4.OrderTypeCode = OrderType4
    WHERE
            OrderHistory.[Quantity] <> 0
            -- Remove Bonded Warehouse
            AND NOT (
                        OrderHistory.[CustomerNumber] = '3824800'
                        AND ISNULL(OrderHistory.[Warehouse], '') = '335'
                    );


