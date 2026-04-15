CREATE TABLE [Pricing_AFI].[FreightCodes]
    (
        [FreightCode]  CHAR(3)      NULL,
        [Description]  VARCHAR(30)  NULL,
        [FreightType]  CHAR(1)      NULL,
        [AddedByUser]         VARCHAR(30)  NULL,
        [DateAdded]         DATETIME2(6) NULL,
        [ChangeByUser]         VARCHAR(30)  NULL,
        [DateChange]         DATETIME2(6) NULL,
        [ActiveRecord]        CHAR(1)      NULL,
        [CurrencyCode] CHAR(3)      NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Pricing_AFI/FreightCodes/AFI_Sales_tblFreightCodes.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],

