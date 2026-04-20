CREATE TABLE [Pricing_AFI].[BuyGroupMaster]
    (
        [BuyGroupCode]  CHAR(3)      NULL,
        [Description]   VARCHAR(25)  NULL,
        [AddedByUser]          VARCHAR(30)  NULL,
        [DateAdded]          DATETIME2(6) NULL,
        [ChangeByUser]          VARCHAR(30)  NULL,
        [DateChange]          DATETIME2(6) NULL,
        [ActiveRecord]         CHAR(1)      NULL,
        [ShowOnInquiry] BIT          NULL,
        [CurrencyCode]  CHAR(3)      NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/Pricing_AFI/BuyGroupMaster/AFI_Sales_tblBuyGroupMaster.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

