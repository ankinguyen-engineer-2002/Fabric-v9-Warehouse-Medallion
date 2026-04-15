CREATE TABLE [Pricing_AFI].[PriceList]
    (
        [PriceCode]            CHAR(6)        NULL,
        [ItemSKU]              VARCHAR(15)    NULL,
        [Price]                DECIMAL(8, 2)  NULL,
        [CommissionBaseAdjust] DECIMAL(8, 2)  NULL,
        [WarehouseOpAdjust]    DECIMAL(5, 2)  NULL,
        [OrderDateStart]       DATE           NULL,  -- DATETIME2(6)
        [OrderDateEnd]         DATE           NULL,  -- DATETIME2(6)
        [AuditFlag]            BIT            NULL,
        [AddedByUser]                 VARCHAR(30)    NULL,
        [DateAdded]                 DATETIME2(6)   NULL,
        [ChangeByUser]                 VARCHAR(30)    NULL,
        [DateChange]                 DATETIME2(6)   NULL,
        [ActiveRecord]                CHAR(1)        NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/Pricing_AFI/PriceList/AFI_Sales_tblPriceList.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

