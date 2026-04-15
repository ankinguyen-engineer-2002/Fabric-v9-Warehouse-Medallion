CREATE TABLE [Marketing].[SalesCategory]
    (
        [SalesCategory]           CHAR(3)       NULL,
        [Description]             VARCHAR(25)   NULL,
        [Division]                CHAR(1)       NULL,
        [MktPotFactor]            DECIMAL(13,5) NULL,  --FLOAT(53) 
        [AddedByUser]                    VARCHAR(30)   NULL,
        [DateAdded]                    DATETIME2(6)  NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]                    VARCHAR(30)   NULL,
        [DateChange]                    DATETIME2(6)  NULL, --DATETIME2 (7) NULL,
        [ActiveRecord]                   CHAR(1)       NULL,
        [ProductLine]             CHAR(1)       NULL,
        [HomestoreProductLine]    CHAR(1)       NULL,
        [ProductDivision]         CHAR(1)       NULL,
        [CommissionClass]         CHAR(2)       NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =    N'/Wholesale/Marketing/SalesCategory/GBL_Sales_tblSalesCategory.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
