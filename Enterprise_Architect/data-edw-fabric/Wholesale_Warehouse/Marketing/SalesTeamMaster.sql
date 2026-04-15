CREATE TABLE [Marketing].[SalesTeamMaster]
    (
        [Team]           CHAR(5)      NULL,
        [CustomerNumber] CHAR(8)      NULL,
        [Dc_Shpno]       CHAR(4)      NULL,
        [Totcount]       INT          NULL,
        [Division]       CHAR(1)      NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ActiveRecord]         CHAR(1)      NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/SalesTeamMaster/GBL_Sales_tblSalesTeamMaster.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
