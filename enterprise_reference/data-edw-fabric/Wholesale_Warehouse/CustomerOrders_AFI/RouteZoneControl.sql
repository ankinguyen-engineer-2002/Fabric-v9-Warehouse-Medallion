CREATE TABLE [CustomerOrders_AFI].[RouteZoneControl]
    (
        [RouteZone]           [CHAR](3)       NULL,
        [Warehouse]           [CHAR](3)       NULL,
        [Region]              [CHAR](3)       NULL,
        [OrderReleaseMinimum] [DECIMAL](7, 0) NULL,
        [TripType]            [CHAR](1)       NULL,
        [RouteMethod]         [CHAR](2)       NULL
    );

--WITH (DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/CODIS/RouteZoneControl/AFI_Codis_RouteZoneControl.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],
