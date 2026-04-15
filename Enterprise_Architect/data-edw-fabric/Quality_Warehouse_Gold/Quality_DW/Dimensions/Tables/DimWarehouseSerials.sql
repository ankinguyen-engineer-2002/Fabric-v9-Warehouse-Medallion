CREATE TABLE [Quality_DW].[DimWarehouseSerials]
    (
        [Warehouse]            CHAR(5)      NOT NULL,
        [SerialNumber]         VARCHAR(30)  NOT NULL,
        [ItemNumber]           VARCHAR(30)  NOT NULL,
        [ActiveStatus]         VARCHAR(12)  NULL,
        [MasterStatus]         VARCHAR(12)  NULL,
        [TransferTripNumber]   VARCHAR(30)  NULL,
        [MasterMOPO]           VARCHAR(30)  NULL,
        [VendorNumber]         CHAR(7)      NULL,
        [VendorName]           VARCHAR(25)  NULL,
        [Location]             VARCHAR(50)  NULL,
        [LicensePlate]         VARCHAR(22)  NULL,
        [ReceivedDate]         DATETIME2(6) NULL, --DATETIME2 (7)
        [TripNumber]           VARCHAR(50)  NULL,
        [ShipDate]             CHAR(1)      NOT NULL,
        [CarbLevel]            CHAR(1)      NOT NULL,
        [RotationSequence]     CHAR(1)      NOT NULL,
        [BornOnDate]           DATETIME2(6) NULL, --DATETIME2 (7)
        [POReceiptToStockDate] DATE         NULL
    );

GO

CREATE STATISTICS [stat_DimWarehouseSerials_ActiveStatus]
    ON [Quality_DW].[DimWarehouseSerials]
    (
        [ActiveStatus]
    );
GO

CREATE STATISTICS [stat_DimWarehouseSerials_ItemNumber]
    ON [Quality_DW].[DimWarehouseSerials]
    (
        [ItemNumber]
    );
GO

CREATE STATISTICS [stat_DimWarehouseSerials_SerialNumber]
    ON [Quality_DW].[DimWarehouseSerials]
    (
        [SerialNumber]
    );
GO

CREATE STATISTICS [stat_DimWarehouseSerials_TransferTripNumber]
    ON [Quality_DW].[DimWarehouseSerials]
    (
        [TransferTripNumber]
    );
GO

CREATE STATISTICS [stat_DimWarehouseSerials_TripNumber]
    ON [Quality_DW].[DimWarehouseSerials]
    (
        [TripNumber]
    );
GO

CREATE STATISTICS [stat_DimWarehouseSerials_Warehouse]
    ON [Quality_DW].[DimWarehouseSerials]
    (
        [Warehouse]
    );
GO

