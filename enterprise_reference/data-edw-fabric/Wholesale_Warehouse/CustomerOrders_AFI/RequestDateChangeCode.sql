CREATE TABLE [CustomerOrders_AFI].[RequestDateChangeCode]
    (
        [ReasonCode]              CHAR(2)     NULL,
        [Description]             VARCHAR(50) NULL,
        [AddDate]                 NUMERIC(8)  NULL,
        [AddUser]                 VARCHAR(10) NULL,
        [ChangeDate]              NUMERIC(8)  NULL,
        [ChangeUser]              VARCHAR(10) NULL,
        [Status]                  CHAR(1)     NULL,
        [CancelFlag]              CHAR(1)     NULL,
        [AvailableToAshleyDirect] CHAR(1)     NULL,
        [AshleyDirectDescription] VARCHAR(25) NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/SalesHistory_AFI/RQDTRCD/AFI_SalesHistory_RQDTRCD.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

