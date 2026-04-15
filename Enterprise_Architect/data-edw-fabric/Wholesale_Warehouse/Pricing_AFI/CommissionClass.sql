CREATE TABLE [Pricing_AFI].[CommissionClass]
    (
        [CommissionClass]  CHAR(2)      NULL,
        [Description]      VARCHAR(25)  NULL,
        [Division]         CHAR(1)      NULL,
        [ReductionFlag]    CHAR(1)      NULL,
        [AddedByUser]             VARCHAR(30)  NULL,
        [DateAdded]             DATETIME2(6) NULL,
        [ChangeByUser]             VARCHAR(30)  NULL,
        [DateChange]             DATETIME2(6) NULL,
        [ActiveRecord]            CHAR(1)      NULL,
        [SalesCategory]    CHAR(3)      NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/Wholesale/Pricing_AFI/CommissionClass/GBL_Sales_tblCommissionClass.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],


