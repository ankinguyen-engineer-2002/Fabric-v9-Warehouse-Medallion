CREATE TABLE [ProductKnowledge].[ItemPublishCodes]
    (
        [PublishCodeID] VARCHAR(15)  NULL,
        [ItemSKU]       VARCHAR(15)  NULL,
        [AddedByUser]          VARCHAR(30)  NULL,
        [DateAdded]          DATETIME2(6) NULL,
        [ChangeByUser]          VARCHAR(30)  NULL,
        [DateChange]          DATETIME2(6) NULL
    );


--    DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/MasterData/ProductKnowledge/ItemPublishCodes/GBL_ProductKnowledge_tblItemPublishCodes.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],
