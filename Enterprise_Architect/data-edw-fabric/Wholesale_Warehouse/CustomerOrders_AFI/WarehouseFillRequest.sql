CREATE TABLE [CustomerOrders_AFI].[WarehouseFillRequest]
    (
        [TripNumber]        INT            NOT NULL,
        [Warehouse]         CHAR(3)        NULL,
        [Cubes]             DECIMAL(10, 2) NULL,
        [RequestedCubes]    DECIMAL(10, 2) NULL,
        [CustomerNumber]    INT            NULL,
        [ShiptoNumber]      CHAR(4)        NULL,
        [RequestUserID]     VARCHAR(10)    NULL,
        [RequestedTime]     DATETIME2(6)   NOT NULL, --Dateteim2(7)
        [ProcessingUserID]  VARCHAR(10)    NULL,
        [ProcessingTime]    DATETIME2(6)   NULL,     --Dateteim2(7)
        [ProcessedFlag]     CHAR(1)        NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/codis_afi/WHFILRQ/AFI_Codis_WHFILRQ.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


