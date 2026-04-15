CREATE TABLE [Marketing].[ProductLineMaster]
    (
        [ProductLineCode]        CHAR(2)      NULL,
        [Description]            VARCHAR(25)  NULL,
        [Division]               CHAR(1)      NULL,
        [CEXCode]                CHAR(3)      NULL,
        [Sort]                   SMALLINT     NULL,
        [ItemSKU]                VARCHAR(15)  NULL,
        [AddedByUser]                   VARCHAR(30)  NULL,
        [DateAdded]                   DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]                   VARCHAR(30)  NULL,
        [DateChange]                   DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ActiveRecord]                  CHAR(1)      NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/ProductLineMaster/GBL_Sales_tblProductLineMaster.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
