CREATE TABLE [Marketing].[MarketPotential]
    (
        [Year]        SMALLINT       NULL,
        [State]       CHAR(2)        NULL,
        [CountyFips]  CHAR(3)        NULL,
        [ProductLine] CHAR(1)        NULL,
        [Amount]      DECIMAL(15, 0) NULL, -- MONEY
        [Percentage]  DECIMAL(5, 4)  NULL,
        [AddedByUser]        VARCHAR(30)    NULL,
        [DateAdded]        DATETIME2(6)   NULL, --- DATETIME2(6)
        [ChangeByUser]        VARCHAR(30)    NULL,
        [DateChange]        DATETIME2(6)   NULL  --- DATETIME2(6)
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/MarketPotential/AFI_Sales_Batch_tblMarketPotential.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
