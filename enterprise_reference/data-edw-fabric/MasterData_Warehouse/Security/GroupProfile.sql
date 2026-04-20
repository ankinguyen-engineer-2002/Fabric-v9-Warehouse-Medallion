CREATE TABLE [Security].[GroupProfile]
    (
        [SecurityID]  INT          NULL,
        [GroupID]     VARCHAR(50)  NULL,
        [Description] VARCHAR(50)  NULL,
        [FlagDev]     BIT          NULL,
        [FlagStage]   BIT          NULL,
        [FlagProd]    BIT          NULL,
        [FlagBeta]    BIT          NULL,
        [AddedByUser]        VARCHAR(40)  NULL,
        [DateAdded]        DATETIME2(6) NULL,  --DATETIME2 (7)
        [ChangeByUser]        VARCHAR(40)  NULL,
        [DateChange]        DATETIME2(6) NULL  --DATETIME2 (7)
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/Security/GroupProfile/GBL_Sales_tblGroupProfile.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

