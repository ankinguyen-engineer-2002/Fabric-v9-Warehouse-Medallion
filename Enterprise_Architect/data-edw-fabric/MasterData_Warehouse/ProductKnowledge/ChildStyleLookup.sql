CREATE TABLE [ProductKnowledge].[ChildStyleLookup]
    (
        [ChildStyleCode] CHAR(3)      NULL,
        [Description]    VARCHAR(65)  NULL,
        [ParentCode]     CHAR(3)      NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL,
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/MasterData/ProductKnowledge/ChildStyleLookup/AFI_DemandPlanning_tblChildStyleLookup.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


