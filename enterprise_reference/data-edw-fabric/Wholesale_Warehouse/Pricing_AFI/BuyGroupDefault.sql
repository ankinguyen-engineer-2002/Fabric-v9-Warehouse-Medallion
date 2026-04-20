CREATE TABLE [Pricing_AFI].[BuyGroupDefault]
    (
        [BuyGroupCode]    CHAR(3)       NOT NULL,  --varchar
        [Warehouse]       CHAR(3)       NOT NULL,  --varchar
        [FreightFlag]     CHAR(1)       NOT NULL,  --varchar
        [OrderDateStart]  DATE          NOT NULL, --DATETIME
        [OrderDateEnd]    DATE          NOT NULL, --DATETIME
        [CommissionRate]  DECIMAL(6, 4) NULL,
        [LastUserChanged] VARCHAR(30)   NOT NULL,
        [AddedByUser]            VARCHAR(30)   NOT NULL,
        [DateAdded]            DATETIME2(6)  NOT NULL,
        [ChangeByUser]            VARCHAR(30)   NOT NULL,
        [DateChange]            DATETIME2(6)  NOT NULL,
        [Discount1]       DECIMAL(6, 4) NULL,
        [Discount2]       DECIMAL(6, 4) NULL,
        [Discount3]       DECIMAL(6, 4) NULL,
        [Discount4]       DECIMAL(6, 4) NULL,
        [Discount5]       DECIMAL(6, 4) NULL,
        [Discount6]       DECIMAL(6, 4) NULL,
        [Discount7]       DECIMAL(6, 4) NULL,
        [UseReduction]    CHAR(1)       NOT NULL  --varchar
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/Pricing_AFI/BuyGroupDefault/AFI_Sales_tblBuyGroupDefault.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],

