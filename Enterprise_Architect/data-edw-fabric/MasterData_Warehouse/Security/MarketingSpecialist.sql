CREATE TABLE [Security].[MarketingSpecialist]
    (
        [SalesCode]   CHAR(5)      NULL,
        [MHS_Name]     CHAR(8)      NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL, --DATETIME2 (7)
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL, --DATETIME2 (7)
        [ActiveRecord]       CHAR(1)      NULL,
        [Rowguid]     VARCHAR(40)  NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/MasterData/Security/MarketingSpecialist/AFI_Sales_tblSecurityMarketingSpecialist.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],


