CREATE TABLE [ProductKnowledge].[RetailSalesCategory]
    (
        [RetailCategory] CHAR(3)      NULL,
        [Description]    VARCHAR(30)  NULL,
        [Division]       CHAR(1)      NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL,
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL
    );


--  DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/MasterData/ProductKnowledge/RetailSalesCategory/GBL_ProductKnowledge_tblRetailSalesCategory.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],
