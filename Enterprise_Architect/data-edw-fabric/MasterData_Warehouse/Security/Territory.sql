CREATE TABLE [Security].[Territory]
    (
        [MHS_Name]    CHAR(8)      NULL,
        [SalesCode]   CHAR(5)      NULL,
        [RepID]       CHAR(5)      NULL,
        [RegionCode]  CHAR(3)      NULL,
        [Division]    CHAR(2)      NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL,
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/MarData/Security/Territory/AFI_Sales_tblSecurityTerritory.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],

