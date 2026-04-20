CREATE TABLE [Pricing_AFI].[PriceExceptions]
    (
        [ItemSKU]              VARCHAR(15)   NOT NULL,
        [CustomerNumber]       CHAR(8)       NOT NULL, --varchar
        [ShiptoNumber]         CHAR(4)       NOT NULL, --varchar
        [Warehouse]            CHAR(3)       NOT NULL, --varchar
        [Discount1]            DECIMAL(5, 4) NOT NULL,
        [Discount2]            DECIMAL(5, 4) NOT NULL,
        [Discount3]            DECIMAL(5, 4) NOT NULL,
        [Discount4]            DECIMAL(5, 4) NOT NULL,
        [Discount5]            DECIMAL(5, 4) NOT NULL,
        [Discount6]            DECIMAL(5, 4) NOT NULL,
        [Discount7]            DECIMAL(5, 4) NOT NULL,
        [Price]                DECIMAL(8, 2) NOT NULL,
        [OrderDateStart]       DATE          NOT NULL, --datetime
        [OrderDateEnd]         DATE          NULL,     --datetime
        [FreightFlag]          CHAR(1)       NOT NULL, --varchar
        [ShiptDateStart]       DATE          NULL,     --datetime
        [ShipDateEnd]          DATE          NULL,     --datetime
        [CommissionRate]       DECIMAL(6, 4) NOT NULL,
        [ReductionFlag]        CHAR(1)       NOT NULL, --varchar
        [ExceptionID]          INT           NOT NULL,
        [CommissionBaseAdjust] DECIMAL(8, 2) NULL,
        [OrderNumber]          VARCHAR(7)    NOT NULL,
        [ItemSequence]         NUMERIC(7)    NOT NULL,
        [BilltoSalesCode]      NUMERIC(5)    NOT NULL,
        [ShiptoSalesCode]      NUMERIC(5)    NOT NULL,
        [ShiptoCommisionSplit] DECIMAL(7, 4) NOT NULL,
        [AuditFlag]            BIT           NOT NULL,
        [AddedByUser]                 VARCHAR(30)   NULL,
        [DateAdded]                 DATETIME2(6)  NULL,     --datetime
        [ChangeByUser]                 VARCHAR(30)   NULL,
        [DateChange]                 DATETIME2(6)  NULL,     --datetime
        [ActiveRecord]                CHAR(1)       NULL      --varchar
    );

--  DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Pricing_AFI/PriceExceptions/AFI_Sales_tblPriceExceptions.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],



