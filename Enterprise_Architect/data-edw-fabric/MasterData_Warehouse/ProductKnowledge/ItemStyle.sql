CREATE TABLE [ProductKnowledge].[ItemStyle]
    (
        [Style]       CHAR(3)      NULL,
        [StyleGroup]  VARCHAR(20)  NULL,
        [Description] VARCHAR(65)  NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL,
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL,
        [ActiveRecord]       CHAR(1)      NULL
    );


--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/ProductKnowledge/ItemStyle/GBL_ProductKnowledge_tblItemStyle.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],
