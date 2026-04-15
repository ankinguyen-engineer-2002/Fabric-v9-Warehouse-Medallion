CREATE TABLE [Security].[GroupPermissions]
    (
        [UserLogin] VARCHAR(25)  NULL,
        [GroupID]   VARCHAR(35)  NULL,
        [Flag]      CHAR(2)      NULL,
        [StatFlag]  CHAR(2)      NULL,
        [PendFlag]  CHAR(2)      NULL,
        [AddedByUser]      VARCHAR(40)  NULL,
        [DateAdded]      DATETIME2(6) NULL,   --DATETIME2 (7)
        [ChangeByUser]      VARCHAR(40)  NULL,
        [DateChange]      DATETIME2(6) NULL    --DATETIME2 (7)
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/MasterData/Security/GroupPermissions/GBL_Sales_tblGroupPermissions.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],




