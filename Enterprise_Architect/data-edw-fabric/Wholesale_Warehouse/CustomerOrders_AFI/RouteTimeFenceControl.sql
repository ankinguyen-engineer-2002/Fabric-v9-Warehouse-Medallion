CREATE TABLE [CustomerOrders_AFI].[RouteTimeFenceControl]
    (
        [ControlKey]    CHAR(10)    NULL,
        [Warehouse]     CHAR(3)     NULL,
        [Value1]        NUMERIC(10) NULL,
        [Value2]        VARCHAR(15) NULL,
        [AddedDate]     DATE        NULL, -- NUMERIC(8)  NULL,
        [AddedTime]     NUMERIC(10) NULL,
        [AddedByUser]   CHAR(10)    NULL,
        [ChangeDate]    DATE        NULL, -- NUMERIC(10) NULL,
        [ChangeTime]    NUMERIC(10) NULL,
        [ChangedByUser] CHAR(10)    NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/CODIS/DESDFTF/AFI_Codis_DESDFTF.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

