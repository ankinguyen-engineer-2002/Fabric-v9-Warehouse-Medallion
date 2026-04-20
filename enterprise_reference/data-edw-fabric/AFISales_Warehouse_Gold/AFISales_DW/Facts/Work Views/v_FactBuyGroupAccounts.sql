CREATE VIEW [AFISales_DW_Wrk].[v_FactBuyGroupAccounts]
AS
    
    SELECT 
        ROW_NUMBER() OVER (ORDER BY Daily.AccountAndShipto)    AS RowID,
        Daily.AccountAndShipto,
        Daily.BuyGroupCode
    FROM    
    (
    SELECT  DISTINCT
            CASE
                WHEN ShippingLocations.ShiptoNumber IS NULL
                     OR ShippingLocations.ShiptoNumber = ''
                    THEN
                    ShippingLocations.CustomerNumber
                ELSE
                    RTRIM(ShippingLocations.CustomerNumber) + '-' + LTRIM(ShippingLocations.ShiptoNumber)
            END AS AccountAndShipto,
            BuyGroupMember.BuyGroupCode
    FROM
            [$(Wholesale_Warehouse)].Customers.ShippingLocations
        INNER JOIN
            [$(Wholesale_Warehouse)].Pricing_AFI.BuyGroupMember
                ON ShippingLocations.CustomerNumber = BuyGroupMember.CustomerNumber
    WHERE
            BuyGroupMember.OrderDateStart <= GETDATE()
            AND
                (
                    ISNULL(BuyGroupMember.OrderDateEnd, GETDATE() + 1) > GETDATE()
                    OR BuyGroupMember.OrderDateEnd = '1900-01-01'
                ) 
     )  Daily

