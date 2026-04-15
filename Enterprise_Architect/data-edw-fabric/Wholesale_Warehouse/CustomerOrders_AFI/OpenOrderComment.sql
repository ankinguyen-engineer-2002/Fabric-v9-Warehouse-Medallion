CREATE TABLE [CustomerOrders_AFI].[OpenOrderComments]
    (
        [OrderNumber] CHAR(7)     NULL,
        [Sequence]    DECIMAL(28) NULL,
        [Comment1]    VARCHAR(50) NULL,
        [Comment2]    VARCHAR(50) NULL,
        [Comment3]    VARCHAR(50) NULL,
        [PrintFlag]   DECIMAL(28) NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/codis_afi/OpenOrderComments/AFI_codis_afi_CODATAK.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

