CREATE TABLE [ProductKnowledge].[LifeStyleArea]
    (
        [LifeStyleID] INT          NULL,
        [Description] VARCHAR(65)  NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL,
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL
    );


--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/MasterData/ProductKnowledge/LifeStyleArea/GBL_ProductKnowledge_tblLifeStyleArea.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

