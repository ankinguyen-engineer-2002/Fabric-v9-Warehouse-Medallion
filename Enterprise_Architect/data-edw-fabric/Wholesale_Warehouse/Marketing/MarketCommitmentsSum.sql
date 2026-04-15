CREATE TABLE [Marketing].[MarketCommitmentsSum]
    (
        [RepID]                       CHAR(5)       NULL,
        [CustomerNumber]              CHAR(8)       NULL,
        [ShiptoNumber]                CHAR(4)       NULL,
        [ItemSKU]                     VARCHAR(15)   NULL,
        [HomeStoreFlag]               BIT           NULL,
        [Committed]                   INT           NULL,
        [Actual]                      INT           NULL,
        [ActualMonthlyQty]            DECIMAL(5, 2) NULL,
        [Goal]                        INT           NULL,
        [MonthlyEstQty]               DECIMAL(5, 2) NULL,
        [OriginalMonthlyEstQty]       DECIMAL(5, 2) NULL,
        [OriginalCommitment]          INT           NULL,
        [Userid]                      VARCHAR(30)   NULL,
        [DateChanged]                 DATETIME2(6)  NULL,
        [AddedByUser]                        VARCHAR(30)   NULL,
        [DateAdded]                        DATETIME2(6)  NULL, --- DATETIME2(6)
        [ChangeByUser]                        VARCHAR(30)   NULL,
        [DateChange]                        DATETIME2(6)  NULL, --- DATETIME2(6)
        [HomestoreCommitted]          INT           NULL,
        [HomestoreOriginalCommitment] INT           NULL,
        [Region]                      CHAR(3)       NULL,
        [HomestoreQty]                INT           NULL,
        [NonHomestoreQty]             INT           NULL
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/MarketCommitmentsSum/AFI_Sales_Batch_tblMarketCommitmentsSum.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
