CREATE TABLE [Pricing_AFI].[CommissionCodes]
    (
        [CommissionCode]  CHAR(3)      NULL,
        [Description]     VARCHAR(30)  NULL,
        [ReductionFlag]   CHAR(1)      NULL,
        [AddedByUser]            VARCHAR(30)  NULL,
        [DateAdded]            DATETIME2(6) NULL,
        [ChangeByUser]            VARCHAR(30)  NULL,
        [DateChange]            DATETIME2(6) NULL,
        [ActiveRecord]           CHAR(1)      NULL,
        [CurrencyCode]    CHAR(3)      NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Pricing_AFI/CommissionCodes/AFI_Sales_tblCommissionCodes.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

