CREATE TABLE [Marketing].[MarketCommitments]
    (
        [Market]              VARCHAR(10)   NULL,
        [RepID]               CHAR(5)       NULL,
        [CustomerNumber]      CHAR(8)       NULL,
        [ShiptoNumber]        CHAR(4)       NULL,
        [HomeStoreFlag]       BIT           NULL,
        [ItemSKU]             VARCHAR(15)   NULL,
        [MonthlyEstQty]       DECIMAL(5, 2) NULL,
        [Commitment]          INT           NULL,
        [UserId]              VARCHAR(30)   NULL,
        [DateChanged]         DATETIME2(6)  NULL, --- DATETIME2(6)
        [AddedByUser]                VARCHAR(30)   NULL,
        [DateAdded]                DATETIME2(6)  NULL, --- DATETIME2(6)
        [ChangeByUser]                VARCHAR(30)   NULL,
        [DateChange]                DATETIME2(6)  NULL, --- DATETIME2(6)
        [HomestoreCommitment] INT           NULL,
        [Region]              CHAR(3)       NULL,
        [HomestoreQty]        INT           NULL,
        [NonHomestoreQty]     INT           NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/MarketCommitments/AFI_Sales_Batch_tblMarketCommitments.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
