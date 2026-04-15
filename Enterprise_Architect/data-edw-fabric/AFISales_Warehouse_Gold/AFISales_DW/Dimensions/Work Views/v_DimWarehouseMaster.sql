CREATE VIEW [AFISales_DW_Wrk].[v_DimWarehouseMaster]
AS
    SELECT
            CAST(TRIM(WarehouseMaster.Warehouse) AS CHAR(3))           AS [Warehouse Code],
            CAST(TRIM(WarehouseMaster.IntransitWarehouse) AS CHAR(3))  AS [Intransit Warehouse],
            CAST(TRIM(WarehouseMaster.ContainerDirectWhse) AS CHAR(1)) AS [Container Direct Warehouse],
            CAST(WarehouseMaster.Controlled AS INT)                    AS [Controlled Warehouse],
            Locations.Description                                      AS [Warehouse Location],
            WarehouseMaster.WarehouseOrderGroup                        AS [Warehouse Order Group]
    FROM
            [$(Wholesale_Warehouse)].CustomerOrders_AFI.WarehouseMaster
        JOIN
            [$(Wholesale_Warehouse)].PartyContacts.Locations
                ON WarehouseMaster.LocationID = Locations.LocationID
        JOIN
            [$(Wholesale_Warehouse)].PartyContacts.AddressMaster
                ON Locations.AddressID = AddressMaster.AddressID;
GO