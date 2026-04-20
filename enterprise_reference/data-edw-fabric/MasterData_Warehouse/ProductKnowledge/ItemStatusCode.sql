CREATE TABLE [ProductKnowledge].[ItemStatusCode]
    (
        [Code]              CHAR(1)      NULL,
        [Description]       VARCHAR(25)  NULL,
        [AddedByUser]              VARCHAR(30)  NULL,
        [DateAdded]              DATETIME2(6) NULL,
        [ChangeByUser]              VARCHAR(30)  NULL,
        [DateChange]              DATETIME2(6) NULL,
        [ActiveRecord]             CHAR(1)      NULL,
        [MapicsStatus]      BIT          NULL,
        [StatusDescription] VARCHAR(30)  NULL
    );


--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/ProductKnowledge/ItemStatusCode/GBL_ProductKnowledge_tblItemStatusCode.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

