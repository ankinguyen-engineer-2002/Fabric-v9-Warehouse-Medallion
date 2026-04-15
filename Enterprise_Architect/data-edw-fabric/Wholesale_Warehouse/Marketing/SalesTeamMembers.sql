CREATE TABLE [Marketing].[SalesTeamMembers]
    (
        [Team]       CHAR(5)      NULL,
        [MarketingSpecialist]      CHAR(5)      NULL,
        [StoreCount] INT          NULL,
        [Division]   CHAR(1)      NULL,
        [AddedByUser]       VARCHAR(30)  NULL,
        [DateAdded]       DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]       VARCHAR(30)  NULL,
        [DateChange]       DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ActiveRecord]      CHAR(1)      NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/SalesTeamMembers/GBL_Sales_tblSalesTeamMembers.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
