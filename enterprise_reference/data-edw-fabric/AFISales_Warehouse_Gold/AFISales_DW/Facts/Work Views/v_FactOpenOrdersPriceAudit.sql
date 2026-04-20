CREATE VIEW [AFISales_DW_Wrk].[v_FactOpenOrdersPriceAudit]
AS
    SELECT DISTINCT
           ROW_NUMBER() OVER (ORDER BY
                                  [Order Taken Date]
                             )                             AS RowID,
           [Order Taken Date],
           [Order Number],
           [Item Sequence Number],
           [Account And Shipto Number],
           [Customer Account Number],
           [Customer Shipto Number],
           [Item Key],
           [Item Sku],
           [Warehouse],
           [Order Amount Without Freight]                  = CAST([Order Amount with Freight] - [Order Freight] AS DECIMAL(19, 2)),
           [Order Quantity],
           [Order Freight]=CAST([Order Freight] AS DECIMAL(19, 2)),
           [Order Item Unit Price]=CAST([Order Item Unit Price] AS DECIMAL(19, 2)),
           [Current Item Unit Price]=CAST([Current Item Unit Price] AS DECIMAL(19, 2)),
           [Discrepency Count]                             = CASE
                                                                 WHEN ABS([Order Item Unit Price] - [Current Item Unit Price]) > .03
                                                                     THEN
                                                                     1
                                                                 ELSE
                                                                     0
                                                             END,
           [Line Item Count]                               = 1,
           [Order Discrepancy]                             = CAST(([Order Item Unit Price] - [Current Item Unit Price]) * [Order Quantity] AS DECIMAL(19, 2)),
           [Base Price Discrepancy]                        = ([Order Base Price] - [Current Base Price]),
           [Unit Price Discrepancy]                        = ([Order Item Unit Price] - [Current Item Unit Price]),
           [Current Amount Without Freight]                = CAST([Current Item Unit Price] * [Order Quantity] AS DECIMAL(19, 2)),
           CAST([Current Base Price] AS DECIMAL(19, 2))    AS [Current Base Price],
           [Current Volume Disc1],
           [Current Hidden Disc2],
           [Current Volume Disc3],
           [Current Coop Accrual],
           [Current Hidden Prem5],
           [Current DFI Disc6],
           [Current Premium Disc7],
           [Current BuyGroup Exception ID],
           [Current BuyGroup Code],
           [Current Exception ID (order)],
           [Current Exception ID (Shipto/Whse)],
           [Current Exception ID (Shipto)],
           [Current Exception ID (Cust/Whse)],
           [Current Exception ID (Cust)],
           [Current Discount Code],
           [Current Discount Class],
           [Current Price Code],
           [Current Container Direct Flag],
           CONVERT(DECIMAL(17, 2), [Order Discount])       AS [Order Discount],
           CONVERT(DECIMAL(17, 2), [Order DFI Discount])   AS [Order DFI Discount],
           [Order Exception ID],
           [Order Discount Code],
           [Order Discount Class],
           [Order Price Code],
           CONVERT(DECIMAL(17, 2), [Order Total Discount]) AS [Order Total Discount],
           [Order BuyGroup Code],
           [Order BuyGroup Exception ID],
           [Order Premium],  
           [Order Base Price],
           [Order FOB Price]
    FROM
           (
               SELECT
                       RANK() OVER (PARTITION BY
                                        OpenOrderDetail.OrderNumber,
                                        OpenOrderDetail.ItemSequence
                                    ORDER BY
                                        OpenOrderDetail.OrderNumber,
                                        OpenOrderDetail.ItemSequence,
                                        BuyGroupPricing.ExceptionID DESC
                                   )                        AS BuyGroupDupCheck,

                                                                         -- Order attributes
                       [Order Taken Date]                   = OpenOrderHeader.OrderDate,
                       [Order Number]                       = OpenOrderDetail.OrderNumber,
                       [Item Sequence Number]               = OpenOrderDetail.ItemSequence,
                       [Account And Shipto Number]          = CASE
                                                                  WHEN OpenOrderDetail.ShiptoNumber IS NULL
                                                                       OR OpenOrderDetail.ShiptoNumber = ''
                                                                      THEN
                                                                      OpenOrderDetail.CustomerNumber
                                                                  ELSE
                                                                      RTRIM(OpenOrderDetail.CustomerNumber) + '-' + LTRIM(OpenOrderDetail.ShiptoNumber)
                                                              END,
                       [Customer Account Number]            = OpenOrderDetail.CustomerNumber,
                       [Customer Shipto Number]             = OpenOrderDetail.ShiptoNumber,
                       [Item Key]                           = 'ASHLEY_' + ISNULL(OpenOrderDetail.ItemSKU, ''),
                       [Item Sku]                           = OpenOrderDetail.ItemSKU,
                       [Warehouse]                          = OpenOrderDetail.Warehouse,

                                                                         -- Order Values
                       [Order Amount with Freight]          = OpenOrderDetail.NetSalesAmount,
                       [Order Quantity]                     = (CASE
                                                                   WHEN OpenOrderDetail.QuantityBackOrdered > 0
                                                                       THEN
                                                                       OpenOrderDetail.QuantityBackOrdered
                                                                   ELSE
                       (CASE
                            WHEN OpenOrderDetail.QuantiyOrdered > 0
                                THEN
                                OpenOrderDetail.QuantiyOrdered
                            ELSE
                                1
                        END
                       )
                                                               END
                                                              ),
                       [Order Freight]                      = OpenOrderExtendedItem.Freight * (CASE
                                                                               WHEN OpenOrderDetail.QuantityBackOrdered > 0
                                                                                   THEN
                                                                                   OpenOrderDetail.QuantityBackOrdered
                                                                               ELSE
                       (CASE
                            WHEN OpenOrderDetail.QuantiyOrdered > 0
                                THEN
                                OpenOrderDetail.QuantiyOrdered
                            ELSE
                                1
                        END
                       )
                                                                           END
                                                                          ),
                       [Order Item Unit Price]              = OpenOrderDetail.NetSalesAmount / (CASE
                                                                              WHEN OpenOrderDetail.QuantityBackOrdered > 0
                                                                                  THEN
                                                                                  OpenOrderDetail.QuantityBackOrdered
                                                                              ELSE
                       (CASE
                            WHEN OpenOrderDetail.QuantiyOrdered > 0
                                THEN
                                OpenOrderDetail.QuantiyOrdered
                            ELSE
                                1
                        END
                       )
                                                                          END
                                                                         ) - OpenOrderExtendedItem.Freight,

                                                                         -- Current price
                       [Current Item Unit Price]            = ROUND(
                                                                       ROUND(
                                                                                ROUND(
                                                                                         ROUND(
                                                                                                  COALESCE(
                                                                                                              Exc1.Price, Exc2.Price,
                                                                                                              Exc3.Price, Exc4.Price,
                                                                                                              Exc5.Price,
                                                                                                              BuyGroupPricing.Price,
                                                                                                              PriceList.Price
                                                                                                          ) --- ingore discount4 = Coop Ad
                                                                                                  * (1.0
                                                                                                     + COALESCE(
                                                                                                                   Exc1.Discount7,
                                                                                                                   Exc2.Discount7,
                                                                                                                   Exc3.Discount7,
                                                                                                                   Exc4.Discount7,
                                                                                                                   Exc5.Discount7,
                                                                                                                   CASE
                                                                                                                       WHEN ISNULL(
                                                                                                                                      BuyGroupPricing.UseDiscountProgram,
                                                                                                                                      'Y'
                                                                                                                                  ) = 'N'
                                                                                                                           THEN
                                                                                                                           BuyGroupPricing.Discount7
                                                                                                                       ELSE
                                                                                                                           Exc5.Discount7
                                                                                                                   END,
                                                                                                                   DiscountRates.Discount7
                                                                                                               )
                                                                                                    ), 2
                                                                                              ) -- hidden premium

                                                                                         * (1.0
                                                                                            - COALESCE(
                                                                                                          Exc1.Discount2, Exc2.Discount2,
                                                                                                          Exc3.Discount2, Exc4.Discount2,
                                                                                                          Exc5.Discount2,
                                                                                                          CASE
                                                                                                              WHEN ISNULL(
                                                                                                                             BuyGroupPricing.UseDiscountProgram,
                                                                                                                             'Y'
                                                                                                                         ) = 'N'
                                                                                                                  THEN
                                                                                                                  BuyGroupPricing.Discount2
                                                                                                              ELSE
                                                                                                                  Exc5.Discount2
                                                                                                          END, DiscountRates.Discount2
                                                                                                      ) -- hidden disc
                                                                                            - COALESCE(
                                                                                                          Exc1.Discount5, Exc2.Discount5,
                                                                                                          Exc3.Discount5, Exc4.Discount5,
                                                                                                          Exc5.Discount5,
                                                                                                          CASE
                                                                                                              WHEN ISNULL(
                                                                                                                             BuyGroupPricing.UseDiscountProgram,
                                                                                                                             'Y'
                                                                                                                         ) = 'N'
                                                                                                                  THEN
                                                                                                                  BuyGroupPricing.Discount5
                                                                                                              ELSE
                                                                                                                  Exc5.Discount5
                                                                                                          END, DiscountRates.Discount5
                                                                                                      )
                                                                                           ), 2
                                                                                     ) -- hidden disc


                                                                                * (1.0
                                                                                   - COALESCE(
                                                                                                 Exc1.Discount1, Exc2.Discount1, Exc3.Discount1,
                                                                                                 Exc4.Discount1, Exc5.Discount1,
                                                                                                 CASE
                                                                                                     WHEN ISNULL(
                                                                                                                    BuyGroupPricing.UseDiscountProgram,
                                                                                                                    'Y'
                                                                                                                ) = 'N'
                                                                                                         THEN
                                                                                                         BuyGroupPricing.Discount1
                                                                                                     ELSE
                                                                                                         Exc5.Discount1
                                                                                                 END, DiscountRates.Discount1
                                                                                             )
                                                                                  ), 2
                                                                            ) --reg volume disc
                                                                       * (1.0
                                                                          - COALESCE(
                                                                                        Exc1.Discount6, Exc2.Discount6, Exc3.Discount6, Exc4.Discount6,
                                                                                        Exc5.Discount6,
                                                                                        CASE
                                                                                            WHEN ISNULL(
                                                                                                           BuyGroupPricing.UseDiscountProgram,
                                                                                                           'Y'
                                                                                                       ) = 'N'
                                                                                                THEN
                                                                                                BuyGroupPricing.Discount6
                                                                                            ELSE
                                                                                                Exc5.Discount6
                                                                                        END, CASE
                                                                                                 WHEN DimWarehouseMaster.[Container Direct Warehouse]  = 'N'
                                                                                                     THEN
                                                                                                     DiscountRates.Discount6
                                                                                                 ELSE
                                                                                                     0
                                                                                             END
                                                                                    )
                                                                         ), 2
                                                                   ),    -- DFI

                                                                         -- Pricing components
                       [Current Base Price]                 = COALESCE(
                                                                          Exc1.Price, Exc2.Price, Exc3.Price, Exc4.Price, Exc5.Price,
                                                                          BuyGroupPricing.Price, PriceList.Price
                                                                      ),
                       [Current Volume Disc1]               = COALESCE(
                                                                          Exc1.Discount1, Exc2.Discount1, Exc3.Discount1, Exc4.Discount1, Exc5.Discount1,
                                                                          CASE
                                                                              WHEN ISNULL(BuyGroupPricing.UseDiscountProgram, 'Y') = 'N'
                                                                                  THEN
                                                                                  BuyGroupPricing.Discount1
                                                                              ELSE
                                                                                  Exc5.Discount1
                                                                          END, DiscountRates.Discount1
                                                                      ), --reg disc
                       [Current Hidden Disc2]               = COALESCE(
                                                                          Exc1.Discount2, Exc2.Discount2, Exc3.Discount2, Exc4.Discount2, Exc5.Discount2,
                                                                          CASE
                                                                              WHEN ISNULL(BuyGroupPricing.UseDiscountProgram, 'Y') = 'N'
                                                                                  THEN
                                                                                  BuyGroupPricing.Discount2
                                                                              ELSE
                                                                                  Exc5.Discount2
                                                                          END, DiscountRates.Discount2 
                                                                      ), -- hidden disc
                       [Current Volume Disc3]               = COALESCE(
                                                                          Exc1.Discount3, Exc2.Discount3, Exc3.Discount3, Exc4.Discount3, Exc5.Discount3,
                                                                          CASE
                                                                              WHEN ISNULL(BuyGroupPricing.UseDiscountProgram, 'Y') = 'N'
                                                                                  THEN
                                                                                  BuyGroupPricing.Discount3
                                                                              ELSE
                                                                                  Exc5.Discount3
                                                                          END, DiscountRates.Discount3
                                                                      ), -- not used
                       [Current Coop Accrual]               = COALESCE(
                                                                          Exc1.Discount4, Exc2.Discount4, Exc3.Discount4, Exc4.Discount4, Exc5.Discount4,
                                                                          CASE
                                                                              WHEN ISNULL(BuyGroupPricing.UseDiscountProgram, 'Y') = 'N'
                                                                                  THEN
                                                                                  BuyGroupPricing.Discount4
                                                                              ELSE
                                                                                  Exc5.Discount4
                                                                          END, DiscountRates.Discount4
                                                                      ), -- coop ad
                       [Current Hidden Prem5]               = COALESCE(
                                                                          Exc1.Discount5, Exc2.Discount5, Exc3.Discount5, Exc4.Discount5, Exc5.Discount5,
                                                                          CASE
                                                                              WHEN ISNULL(BuyGroupPricing.UseDiscountProgram, 'Y') = 'N'
                                                                                  THEN
                                                                                  BuyGroupPricing.Discount5
                                                                              ELSE
                                                                                  Exc5.Discount5
                                                                          END, DiscountRates.Discount5
                                                                      ), -- hidden disc
                       [Current DFI Disc6]                  = COALESCE(
                                                                          Exc1.Discount6, Exc2.Discount6, Exc3.Discount6, Exc4.Discount6, Exc5.Discount6,
                                                                          CASE
                                                                              WHEN ISNULL(BuyGroupPricing.UseDiscountProgram, 'Y') = 'N'
                                                                                  THEN
                                                                                  BuyGroupPricing.Discount6
                                                                              ELSE
                                                                                  Exc5.Discount6
                                                                          END, CASE
                                                                                   WHEN DimWarehouseMaster.[Container Direct Warehouse]  = 'N'
                                                                                       THEN
                                                                                       DiscountRates.Discount6
                                                                                   ELSE
                                                                                       0
                                                                               END
                                                                      ), -- DFI
                       [Current Premium Disc7]              = COALESCE(
                                                                          Exc1.Discount7, Exc2.Discount7, Exc3.Discount7, Exc4.Discount7, Exc5.Discount7,
                                                                          CASE
                                                                              WHEN ISNULL(BuyGroupPricing.UseDiscountProgram, 'Y') = 'N'
                                                                                  THEN
                                                                                  BuyGroupPricing.Discount7
                                                                              ELSE
                                                                                  Exc5.Discount7
                                                                          END, DiscountRates.Discount7
                                                                      ), -- hidden premium

                                                                         -- Pricing codes
                       [Current BuyGroup Exception ID]      = BuyGroupPricing.ExceptionID,
                       [Current BuyGroup Code]              = BuyGroupPricing.BuyGroupCode,
                       [Current Exception ID (order)]       = Exc1.[ExceptionID],
                       [Current Exception ID (Shipto/Whse)] = Exc2.[ExceptionID],
                       [Current Exception ID (Shipto)]      = Exc3.[ExceptionID],
                       [Current Exception ID (Cust/Whse)]   = Exc4.[ExceptionID],
                       [Current Exception ID (Cust)]        = Exc5.[ExceptionID],
                       [Current Discount Code]              = DimCustomers.[Discount Code],
                       [Current Discount Class]             = DiscountClassCode,
                       [Current Price Code]                 = DimCustomers.[Price Code],
                       [Current Container Direct Flag]      = DimWarehouseMaster.[Container Direct Warehouse] ,


                                                                         --- Order codes
                       [Order Discount]                     = OpenOrderExtendedItem.Discount,
                       [Order DFI Discount]                 = OpenOrderExtendedItem.DFIDiscount,
                       [Order Exception ID]                 = OpenOrderExtendedItem.ExeptionID,
                       [Order Discount Code]                = OpenOrderExtendedItem.CustomerDiscountCode,
                       [Order Discount Class]               = OpenOrderExtendedItem.ItemDiscountClass,
                       [Order Price Code]                   = OpenOrderExtendedItem.PriceCode,
                       [Order Total Discount]               = OpenOrderExtendedItem.ItemDescription,
                       [Order BuyGroup Code]                = OpenOrderExtendedItem.BuyGroupCode,
                       [Order BuyGroup Exception ID]        = OpenOrderExtendedItem.GroupPriceExceptionID,
                       [Order Premium]                      = OpenOrderExtendedItem.PriceAdderRate,
                       [Order Base Price]                   = OpenOrderExtendedItem.ContractPrice,
                       [Order FOB Price]                    = OpenOrderExtendedItem.StandardPrice
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
                   LEFT JOIN
                       AFISales_DW.DimWarehouseMaster
                           ON OpenOrderDetail.Warehouse = DimWarehouseMaster.[Warehouse Code]
                   LEFT JOIN
                       AFISales_DW.DimCustomers
                           ON DimCustomers.[Customer Account Number] = OpenOrderDetail.CustomerNumber
                              AND DimCustomers.[Customer Shipto Number] = OpenOrderDetail.ShiptoNumber
                   LEFT JOIN
                       AFISales_DW.DimItemMaster
                           ON DimItemMaster.ItemSKU = OpenOrderDetail.ItemSKU
                   LEFT JOIN
                       [$(Wholesale_Warehouse)].Pricing_AFI.PriceList
                           ON PriceList.PriceCode = DimCustomers.[Price Code]
                              AND PriceList.ItemSKU = OpenOrderDetail.ItemSKU
                   LEFT JOIN
                       [$(Wholesale_Warehouse)].Pricing_AFI.PriceExceptions Exc1
                           ON Exc1.ItemSKU = OpenOrderDetail.ItemSKU
                              AND Exc1.CustomerNumber = OpenOrderDetail.CustomerNumber
                              AND Exc1.ShiptoNumber = OpenOrderDetail.ShiptoNumber
                              AND Exc1.OrderNumber = OpenOrderDetail.OrderNumber
                              AND Exc1.ItemSequence = OpenOrderDetail.ItemSequence
                              AND OpenOrderHeader.OrderDate
                              BETWEEN Exc1.OrderDateStart AND Exc1.OrderDateEnd
                              AND ISNULL(Exc1.ShipDateEnd, GETDATE() + 10) > GETDATE()
                              AND Exc1.ActiveRecord <> 'S'
                   LEFT JOIN
                       [$(Wholesale_Warehouse)].Pricing_AFI.PriceExceptions Exc2
                           ON Exc2.ItemSKU = OpenOrderDetail.ItemSKU
                              AND Exc2.CustomerNumber = OpenOrderDetail.CustomerNumber
                              AND Exc2.ShiptoNumber = OpenOrderDetail.ShiptoNumber
                              AND Exc2.Warehouse = OpenOrderDetail.Warehouse
                              AND Exc2.OrderNumber = ''
                              AND OpenOrderHeader.OrderDate
                              BETWEEN Exc2.OrderDateStart AND Exc2.OrderDateEnd
                              AND ISNULL(Exc2.ShipDateEnd, GETDATE() + 10) > GETDATE()
                              AND Exc2.ActiveRecord <> 'S'
                   LEFT JOIN
                       [$(Wholesale_Warehouse)].Pricing_AFI.PriceExceptions Exc3
                           ON Exc3.ItemSKU = OpenOrderDetail.ItemSKU
                              AND Exc3.CustomerNumber = OpenOrderDetail.CustomerNumber
                              AND Exc3.ShiptoNumber = OpenOrderDetail.ShiptoNumber
                              AND Exc3.Warehouse = ''
                              AND Exc3.OrderNumber = ''
                              AND OpenOrderHeader.OrderDate
                              BETWEEN Exc3.OrderDateStart AND Exc3.OrderDateEnd
                              AND ISNULL(Exc3.ShipDateEnd, GETDATE() + 10) > GETDATE()
                              AND Exc3.ActiveRecord <> 'S'
                   LEFT JOIN
                       [$(Wholesale_Warehouse)].Pricing_AFI.PriceExceptions Exc4
                           ON Exc4.ItemSKU = OpenOrderDetail.ItemSKU
                              AND Exc4.CustomerNumber = OpenOrderDetail.CustomerNumber
                              AND Exc4.ShiptoNumber = ''
                              AND Exc4.Warehouse = OpenOrderDetail.Warehouse
                              AND Exc4.OrderNumber = ''
                              AND OpenOrderHeader.OrderDate
                              BETWEEN Exc4.OrderDateStart AND Exc4.OrderDateEnd
                              AND ISNULL(Exc4.ShipDateEnd, GETDATE() + 10) > GETDATE()
                              AND Exc4.ActiveRecord <> 'S'
                   LEFT JOIN
                       [$(Wholesale_Warehouse)].Pricing_AFI.PriceExceptions Exc5
                           ON Exc5.ItemSKU = OpenOrderDetail.ItemSKU
                              AND Exc5.CustomerNumber = OpenOrderDetail.CustomerNumber
                              AND Exc5.ShiptoNumber = ''
                              AND Exc5.Warehouse = ''
                              AND Exc5.OrderNumber = ''
                              AND OpenOrderHeader.OrderDate
                              BETWEEN Exc5.OrderDateStart AND Exc5.OrderDateEnd
                              AND ISNULL(Exc5.ShipDateEnd, GETDATE() + 10) > GETDATE()
                              AND Exc5.ActiveRecord <> 'S'
                   LEFT JOIN
                       (
                           SELECT
                                   BuyGroupMember.CustomerNumber,
                                   BuyGroupMember.ShiptoNumber,
                                   BuyGroupMember.OrderDateEnd AS MemberDateStart,
                                   ISNULL(BuyGroupMember.OrderDateEnd, GETDATE() + 10) AS MemberDateEnd,
                                   BuyGroupPrice.BuyGroupCode,
                                   BuyGroupPrice.Warehouse,
                                   BuyGroupPrice.ItemSKU,
                                   BuyGroupPrice.OrderDateStart,
                                   BuyGroupPrice.OrderDateEnd,
                                   BuyGroupPrice.ExceptionID,
                                   BuyGroupMember.UseDiscountProgram,
                                   BuyGroupPrice.Price,
                                   BuyGroupPrice.Discount1,
                                   BuyGroupPrice.Discount2,
                                   BuyGroupPrice.Discount3,
                                   BuyGroupPrice.Discount4,
                                   BuyGroupPrice.Discount5, 
                                   BuyGroupPrice.Discount6,
                                   BuyGroupPrice.Discount7
                           FROM
                                   [$(Wholesale_Warehouse)].Pricing_AFI.BuyGroupMember
                               LEFT JOIN
                                   [$(Wholesale_Warehouse)].Pricing_AFI.BuyGroupPrice
                                       ON BuyGroupMember.BuyGroupCode = BuyGroupPrice.BuyGroupCode
                       )                                              BuyGroupPricing
                           ON BuyGroupPricing.CustomerNumber = OpenOrderDetail.CustomerNumber
                              AND BuyGroupPricing.ShiptoNumber IN (
                                                                     '', OpenOrderDetail.ShiptoNumber
                                                                 )
                              AND BuyGroupPricing.Warehouse IN (
                                                                 '', OpenOrderDetail.Warehouse
                                                             )
                              AND BuyGroupPricing.ItemSKU = OpenOrderDetail.ItemSKU
                              AND OpenOrderHeader.OrderDate
                              BETWEEN BuyGroupPricing.OrderDateStart AND BuyGroupPricing.OrderDateEnd
                   LEFT JOIN
                       [$(Wholesale_Warehouse)].Pricing_AFI.DiscountRates   
                           ON DimCustomers.[Discount Code] = DiscountRates.DiscountCode
                              AND DimItemMaster.DiscountClassCode = DiscountRates.DiscountClass
               WHERE
                       (
                           OpenOrderDetail.QuantityBackOrdered <> 0
                           OR OpenOrderDetail.QuantiyOrdered <> 0
                       )
                       AND PriceList.Price <> 0
                       AND OpenOrderHeader.ActiveRecord <> 'X'
                       AND OpenOrderDetail.QuantiyOrdered >= 0
           ) OrderAudit
    WHERE
           ISNULL(BuyGroupDupCheck, 1) = 1; ---If more than 1 BuyGroup price is active, grab the latest
