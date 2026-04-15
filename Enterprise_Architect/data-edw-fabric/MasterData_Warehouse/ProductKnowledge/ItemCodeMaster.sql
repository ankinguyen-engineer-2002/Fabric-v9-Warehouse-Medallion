CREATE TABLE [ProductKnowledge].[ItemCodeMaster]
    (
        [ItemCodeID]  INT          NULL,
        [Description] VARCHAR(25)  NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL,
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL
    );
--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/ProductKnowledge/ItemCodeMaster/GBL_ProductKnowledge_tblItemCodeMaster.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],
