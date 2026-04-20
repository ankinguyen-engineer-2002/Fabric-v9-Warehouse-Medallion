CREATE VIEW [AFISales_DW_Wrk].[v_FactOrderMinimum]
AS

    SELECT
            ROW_NUMBER() OVER(ORDER BY InvoiceHeader.InvoiceDate) AS RowID,
            [Invoice Date]    = InvoiceHeader.InvoiceDate,
            CASE
                WHEN InvoiceHeader.ShiptoNumber IS NULL
                     OR InvoiceHeader.ShiptoNumber = ''
                    THEN
                    InvoiceHeader.CustomerNumber
                ELSE
                    RTRIM(InvoiceHeader.CustomerNumber) + '-' + LTRIM(InvoiceHeader.ShiptoNumber)
            END               AS [Account And Shipto Number],
            [Invoice Number]  = InvoiceHeader.InvoiceNumber,
            [Order Minimum $] = CASE
                                    WHEN ExtendedCustomerProfile.OrderMinimum IS NOT NULL
                                         AND ExtendedCustomerProfile.OrderMinimum <> '0'
                                        THEN
                                        ExtendedCustomerProfile.OrderMinimum
                                    WHEN ExtendedCustomerProfile.OrderMinimum IS NULL
                                         OR ExtendedCustomerProfile.OrderMinimum = '0'
                                        THEN
                                        CASE
                                            WHEN RouteZoneControl.OrderReleaseMinimum IS NULL
                                                 OR RouteZoneControl.OrderReleaseMinimum = '0'
                                                THEN
                                                DimWarehouseMaster.[Order Release Minimum] 
                                            ELSE
                                                RouteZoneControl.OrderReleaseMinimum 
                                        END
                                END,
            CASE
                WHEN InvoiceHeader.[InvoiceAmount] > CASE
                                           WHEN ExtendedCustomerProfile.OrderMinimum IS NOT NULL
                                                AND ExtendedCustomerProfile.OrderMinimum <> '0'
                                               THEN
                                               ExtendedCustomerProfile.OrderMinimum
                                           WHEN ExtendedCustomerProfile.OrderMinimum IS NULL
                                                OR ExtendedCustomerProfile.OrderMinimum = '0'
                                               THEN
                                               CASE
                                                   WHEN RouteZoneControl.OrderReleaseMinimum IS NULL
                                                        OR RouteZoneControl.OrderReleaseMinimum = '0'
                                                       THEN
                                                       DimWarehouseMaster.[Order Release Minimum] 
                                                   ELSE
                                                       RouteZoneControl.OrderReleaseMinimum
                                               END
                                       END
                    THEN
                    'Y'
                ELSE
                    'N'
            END               AS [Order Minimum],
            CASE
                WHEN InvoiceHeader.[InvoiceAmount] > CASE
                                           WHEN ExtendedCustomerProfile.OrderMinimum IS NOT NULL
                                                AND ExtendedCustomerProfile.OrderMinimum <> '0'
                                               THEN
                                               ExtendedCustomerProfile.OrderMinimum
                                           WHEN ExtendedCustomerProfile.OrderMinimum IS NULL
                                                OR ExtendedCustomerProfile.OrderMinimum = '0'
                                               THEN
                                               CASE
                                                   WHEN RouteZoneControl.OrderReleaseMinimum IS NULL
                                                        OR RouteZoneControl.OrderReleaseMinimum = '0'
                                                       THEN
                                                       DimWarehouseMaster.[Order Release Minimum]  
                                                   ELSE
                                                       RouteZoneControl.OrderReleaseMinimum
                                               END
                                       END
                    THEN
                    1
                ELSE
                    0
            END               AS [Order Minimum Met],
            1                 AS [OM Base Calc],
            InvoiceHeader.[Warehouse] AS [Warehouse],
            ShippingLocations.BuyerAddressID AS [Store Address ID],
            ShippingLocations.RouteAddressID AS [Shipto AddressID],
            CASE
                WHEN CAST(ShippingLocations.ShippingTerritory AS INT) = 0
                    THEN
                    AccountMaster.PrimaryTerritory
                ELSE
                    CAST(AccountMaster.PrimaryTerritory AS CHAR(5)) + CAST(ShippingLocations.ShippingTerritory AS CHAR(5))
            END               AS Territory,
            InvoiceHeader.[ShiptoState]
    FROM
            [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceHeader
        JOIN
            [$(Wholesale_Warehouse)].Customers.ShippingLocations
                ON ShippingLocations.CustomerNumber = InvoiceHeader.CustomerNumber
                   AND ShippingLocations.ShiptoNumber = InvoiceHeader.ShiptoNumber
        JOIN
            [$(Wholesale_Warehouse)].Customers.AccountMaster
                ON AccountMaster.CustomerNumber = InvoiceHeader.CustomerNumber
        LEFT JOIN
            [$(Wholesale_Warehouse)].Customers.ExtendedCustomerProfile
                ON InvoiceHeader.CustomerNumber = ExtendedCustomerProfile.CustomerNumber
                   AND InvoiceHeader.ShiptoNumber = ExtendedCustomerProfile.ShiptoNumber
        LEFT JOIN 
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.RouteZoneControl
                ON RouteZoneControl.Warehouse = InvoiceHeader.Warehouse
                   AND RouteZoneControl.RouteZone = ExtendedCustomerProfile.RouteZone
        LEFT JOIN
            AFISales_DW.DimWarehouseMaster
                ON DimWarehouseMaster.[Warehouse Code] = InvoiceHeader.Warehouse 
    WHERE
            InvoiceHeader.InvoiceDate >= GETDATE() - 1100;