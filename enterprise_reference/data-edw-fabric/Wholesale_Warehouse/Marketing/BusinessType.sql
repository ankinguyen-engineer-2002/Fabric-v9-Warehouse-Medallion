CREATE TABLE [Marketing].[BusinessType]
    (
        [BusinessTypeCode]     CHAR(2)      NULL,
        [Description]          VARCHAR(30)  NULL,
        [BusinessTypeGroup]    CHAR(5)      NULL,
        [Locator]               BIT          NULL,
        [Rental]                BIT          NULL,
        [AddedByUser]                  VARCHAR(30)  NULL,
        [DateAdded]                  DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]                  VARCHAR(30)  NULL,
        [DateChange]                  DATETIME2(6) NULL, --- DATETIME2(6)
        [ActiveRecord]                 CHAR(1)      NULL,
        [RptBusType]            VARCHAR(50)  NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/BusinessType/GBL_Sales_tblBusinessType.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

