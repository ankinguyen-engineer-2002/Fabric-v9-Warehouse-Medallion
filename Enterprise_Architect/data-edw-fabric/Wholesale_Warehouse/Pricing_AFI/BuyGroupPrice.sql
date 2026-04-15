CREATE TABLE [Pricing_AFI].[BuyGroupPrice]
    (
        [BuyGroupCode]      CHAR(3)       NULL,
        [Warehouse]         CHAR(3)       NULL,
        [ItemSKU]           VARCHAR(15)   NULL,
        [Price]             DECIMAL(8, 2) NULL,
        [FreightFlag]       CHAR(1)       NULL,
        [OrderDateStart]    DATE          NULL, --DATETIME2(6)
        [OrderDateEnd]      DATE          NULL, --DATETIME2(6)
        [ShipDateStart]     DATE          NULL, --DATETIME2(6)
        [ShipDateEnd]       DATE          NULL, --DATETIME2(6)
        [CommissonDollor]   DECIMAL(8, 3) NULL,
        [CommissionRate]    DECIMAL(6, 4) NULL,
        [Discount1]         DECIMAL(6, 4) NULL,
        [Discount2]         DECIMAL(6, 4) NULL,
        [Discount3]         DECIMAL(6, 4) NULL,
        [Discount4]         DECIMAL(6, 4) NULL,
        [Discount5]         DECIMAL(6, 4) NULL,
        [Discount6]         DECIMAL(6, 4) NULL,
        [Discount7]         DECIMAL(6, 4) NULL,
        [ExceptionID]       INT           NULL,
        [ReductionFlag]     CHAR(1)       NULL,
        [AuditFlag]         BIT           NULL,
        [AddedByUser]              VARCHAR(30)   NULL,
        [DateAdded]              DATETIME2(6)  NULL,
        [ChangeByUser]              VARCHAR(30)   NULL,
        [DateChange]              DATETIME2(6)  NULL,
        [ActiveRecord]             CHAR(1)       NULL
    );
--   DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Pricing_AFI/BuyGroupPrice/AFI_Sales_tblBuyGroupPrice.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],

