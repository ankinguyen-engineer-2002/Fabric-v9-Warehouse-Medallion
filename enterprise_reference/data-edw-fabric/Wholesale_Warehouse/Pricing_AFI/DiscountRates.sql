CREATE TABLE [Pricing_AFI].[DiscountRates]
    (
        [DiscountCode]   CHAR(3)       NULL,
        [DiscountClass]  CHAR(2)       NULL,
        [Discount1]      DECIMAL(6, 4) NULL,
        [Discount2]      DECIMAL(6, 4) NULL,
        [Discount3]      DECIMAL(6, 4) NULL,
        [Discount4]      DECIMAL(6, 4) NULL,
        [Discount5]      DECIMAL(6, 4) NULL,
        [Discount6]      DECIMAL(6, 4) NULL,
        [Discount7]      DECIMAL(6, 4) NULL,
        [OrderStartDate] DATE          NULL,  --DateTime
        [OrderEndDate]   DATE          NULL,  --DateTime
        [AuditFlag]      BIT           NULL,
        [AddedByUser]           VARCHAR(30)   NULL,
        [DateAdded]           DATETIME2(6)  NULL,
        [ChangeByUser]           VARCHAR(30)   NULL,
        [DateChange]           DATETIME2(6)  NULL,
        [ActiveRecord]          CHAR(1)       NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/Pricing_AFI/DiscountRates/AFI_Sales_tblDiscountRates.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

