CREATE TABLE [Pricing_AFI].[DiscountClass]
    (
        [DiscountClass] CHAR(2)      NULL,
        [Description]   VARCHAR(25)  NULL,
        [Division]      CHAR(1)      NULL,
        [AddedByUser]          VARCHAR(30)  NULL,
        [DateAdded]          DATETIME2(6) NULL,
        [ChangeByUser]          VARCHAR(30)  NULL,
        [DateChange]          DATETIME2(6) NULL,
        [ActiveRecord]         CHAR(1)      NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/Wholesale/Pricing_AFI/DiscountClass/GBL_Sales_tblDiscountClass.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],

