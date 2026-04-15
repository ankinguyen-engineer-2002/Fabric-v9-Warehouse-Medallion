CREATE TABLE [ProductKnowledge].[SetApplications]
    (
        [SetNumber]      VARCHAR(15)  NULL,
        [Application]    CHAR(2)      NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL, --DateTime2(7)
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL  --DateTime2(7)
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/MasterData/ProductKnowledge/SetApplications/GBL_ProductKnowledge_tblSetApplications.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],

