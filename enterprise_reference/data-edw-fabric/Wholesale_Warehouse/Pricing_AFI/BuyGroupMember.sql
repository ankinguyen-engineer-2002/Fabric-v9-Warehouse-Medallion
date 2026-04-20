CREATE TABLE [Pricing_AFI].[BuyGroupMember]
    (
        [CustomerNumber]     CHAR(8)      NULL,
        [ShiptoNumber]       CHAR(4)      NULL,
        [OrderDateStart]     DATE         NULL,  --DATETIME2
        [OrderDateEnd]       DATE         NULL,  --DATETIME2
        [BuyGroupCode]       CHAR(3)      NULL,
        [AuditFlag]          BIT          NULL,
        [AddedByUser]               VARCHAR(30)  NULL,
        [DateAdded]               DATETIME2(6) NULL,
        [ChangeByUser]               VARCHAR(30)  NULL,
        [DateChange]               DATETIME2(6) NULL,
        [ActiveRecord]       CHAR(1)      NULL,
        [UseDiscountProgram] CHAR(1)      NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Pricing_AFI/BuyGroupMember/AFI_Sales_tblBuyGroupMember.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

