CREATE TABLE [Pricing_AFI].[PriceCode]
    (
        [PriceCode]        CHAR(6)      NULL,
        [Description]      VARCHAR(30)  NULL,
        [AshleyFlag]       CHAR(1)      NULL,
        [MilleniumFlag]    CHAR(1)      NULL,
        [AddedByUser]             VARCHAR(30)  NULL,
        [DateAdded]             DATETIME2(6) NULL,
        [ChangeByUser]             VARCHAR(30)  NULL,
        [DateChange]             DATETIME2(6) NULL,
        [ActiveRecord]            CHAR(1)      NULL,
        [DefaultBasePrice] CHAR(1)      NULL,
        [IncludeVAT]       CHAR(1)      NULL,   ---char(10)
        [CurrencyCode]     CHAR(3)      NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Pricing_AFI/PriceCode/AFI_Sales_tblPriceCode.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],


