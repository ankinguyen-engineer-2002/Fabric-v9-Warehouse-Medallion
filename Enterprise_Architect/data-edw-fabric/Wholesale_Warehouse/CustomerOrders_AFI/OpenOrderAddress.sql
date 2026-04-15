CREATE TABLE [CustomerOrders_AFI].[OpenOrderAddress]
    (
        [OrderNumber]    CHAR(7)     NOT NULL,
        [ShiptoName]     VARCHAR(25) NULL,
        [ShiptoAddress1] VARCHAR(25) NULL,
        [ShiptoAddress2] VARCHAR(25) NULL,
        [ShiptoAddress3] VARCHAR(25) NULL,
        [ShiptoState]    CHAR(2)     NULL,
        [ShiptoZipCode]  CHAR(10)    NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/codis_afi/CODATAH/AFI_codis_afi_CODATAH.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],


