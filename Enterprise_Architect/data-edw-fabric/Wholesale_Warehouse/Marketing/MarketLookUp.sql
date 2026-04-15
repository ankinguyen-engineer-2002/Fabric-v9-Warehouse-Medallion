CREATE TABLE [Marketing].[MarketLookup]
    (
        [MarketID]       VARCHAR(10)  NULL,
        [Code]           VARCHAR(30)  NULL,
        [StartDate]      DATE         NULL, --- DATETIME2(6)
        [EndDate]        DATE         NULL, --- DATETIME2(6)
        [AddedByUser]    VARCHAR(30)  NULL,
        [DateAdded]      DATETIME2(6) NULL, --- DATETIME2(6),
        [ChangeByUser]   VARCHAR(30)  NULL,
        [DateChange]     DATETIME2(6) NULL  --- DATETIME2(6)
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/MarketLookup/GBL_Sales_tblMarketLookup.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
