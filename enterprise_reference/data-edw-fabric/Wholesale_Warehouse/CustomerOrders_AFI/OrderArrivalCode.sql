CREATE TABLE [CustomerOrders_AFI].[OrderArrivalCode]
    (
        [OrderArrivalCode]   CHAR(2)      NULL,
        [Description]        VARCHAR(25)  NULL,
        [OrderArrivalType]   CHAR(1)      NULL,
        [SequenceNumber]     INT          NULL,
        [usra]               VARCHAR(30)  NULL,
        [dtea]               DATETIME2(6) NULL,  --Datetime2(7)
        [usrc]               VARCHAR(30)  NULL,
        [dtec]               DATETIME2(6) NULL,  --Datetime2(7)
        [ActiveRecord]              CHAR(1)      NULL,
        [ModeGroup]          INT          NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/Wholesale/codis_afi/OrderArrivalCode/GBL_Sales_tblOrderArrivalCode.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

