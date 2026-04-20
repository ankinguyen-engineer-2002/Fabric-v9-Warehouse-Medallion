CREATE TABLE [ProductKnowledge].[ItemGrouping]
    (
        [ItemSKU]      VARCHAR(15)  NULL,
        [GroupID]      SMALLINT     NULL,
        [AddedByUser]         VARCHAR(30)  NULL,
        [DateAdded]         DATETIME2(6) NULL,
        [ChangeByUser]         VARCHAR(30)  NULL,
        [DateChange]         DATETIME2(6) NULL,
        [ActiveRecord]        CHAR(1)      NULL,
        [DefaultGroup] BIT          NULL
    );
--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/ProductKnowledge/ItemGrouping/GBL_ProductKnowledge_tblItemGrouping.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],
