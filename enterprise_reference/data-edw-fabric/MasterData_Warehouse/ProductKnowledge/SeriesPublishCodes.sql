CREATE TABLE  [ProductKnowledge].[SeriesPublishCodes]
    (
        [PublishCodeID] VARCHAR(15)  NULL,
        [SeriesCode]    VARCHAR(16)  NULL,
        [AddedByUser]          VARCHAR(30)  NULL,
        [DateAdded]          DATETIME2(6) NULL,
        [ChangeByUser]          VARCHAR(30)  NULL,
        [DateChange]          DATETIME2(6) NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/MasterData/ProductKnowledge/SeriesPublishCodes/GBL_ProductKnowledge_tblSeriesPublishCodes.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


