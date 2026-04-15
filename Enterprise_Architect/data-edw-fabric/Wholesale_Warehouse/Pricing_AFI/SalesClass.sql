CREATE TABLE [Pricing_AFI].[SalesClass]
    (
        [SalesClass]      CHAR(2)      NOT NULL,
        [Description]     VARCHAR(25)  NOT NULL,
        [DiscountClass]   CHAR(2)      NOT NULL,
        [FreightClass]    CHAR(2)      NOT NULL,
        [CommissionClass] CHAR(2)      NOT NULL,
        [Division]        CHAR(1)      NOT NULL,
        [AddedByUser]            VARCHAR(30)  NULL,
        [DateAdded]            DATETIME2(6) NULL,
        [ChangeByUser]            VARCHAR(30)  NULL,
        [DateChange]            DATETIME2(6) NULL,
        [ActiveRecord]           CHAR(1)      NOT NULL
    );
--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/Pricing_AFI/Saleass/AFI_Sales_tblSaleass.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


