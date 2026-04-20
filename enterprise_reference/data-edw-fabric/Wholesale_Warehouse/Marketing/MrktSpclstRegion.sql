CREATE TABLE [Marketing].[MrktSpclstRegion]
    (
        [MarketingSpecialist]       CHAR(5)      NULL,
        [RepID]       CHAR(5)      NULL,
        [Division]    CHAR(1)      NULL,
        [Region]     CHAR(3)      NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL, --- DATETIME2(6)
        [ActiveRecord]       CHAR(1)      NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/MrktSpclstRegion/GBL_Sales_tblMrktSpclstRegion.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
