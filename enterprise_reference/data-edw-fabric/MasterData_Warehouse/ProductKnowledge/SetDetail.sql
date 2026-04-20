CREATE TABLE [ProductKnowledge].[SetDetail]
    (
        [CustomerNumber] CHAR(8)      NULL,
        [SetNumber]      VARCHAR(15)  NULL,
        [ItemSKU]        VARCHAR(15)  NULL,
        [Quantity]       DECIMAL(3)   NULL,
        [Key]            BIT          NULL,
        [Option]         BIT          NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL,
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/MasterData/ProductKnowledge/SetDetail/GBL_ProductKnowledge_tblSetDetail.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],
