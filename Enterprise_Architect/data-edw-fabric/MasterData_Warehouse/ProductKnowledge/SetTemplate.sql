CREATE TABLE [ProductKnowledge].[SetTemplate]
    (
        [TemplateID]    VARCHAR(15)  NULL,
        [Description]   VARCHAR(60)  NULL,
        [Ranking]       CHAR(2)      NULL,
        [Sort]          DECIMAL(2)   NULL,
        [ShortDescr]    VARCHAR(30)  NULL,
        [AddedByUser]          VARCHAR(30)  NULL,
        [DateAdded]          DATETIME2(6) NULL, --DateTime2(7)
        [ChangeByUser]          VARCHAR(30)  NULL,
        [DateChange]          DATETIME2(6) NULL  --DateTime2(7)
    );
-- DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/ProductKnowledge/SetTemplate/GBL_ProductKnowledge_tblSetTemplate.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],


