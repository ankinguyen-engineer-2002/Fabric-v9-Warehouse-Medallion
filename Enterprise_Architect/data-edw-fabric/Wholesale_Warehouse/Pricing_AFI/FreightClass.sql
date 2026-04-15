CREATE TABLE [Pricing_AFI].[FreightClass]
    (
        [FreightClass]  CHAR(2)      NULL,
        [Description]   VARCHAR(25)  NULL,
        [FreightType]   VARCHAR(10)  NULL,  --char
        [Division]      CHAR(1)      NULL,
        [Warehouse]     BIT          NULL,
        [AddedByUser]          VARCHAR(30)  NULL,
        [DateAdded]          DATETIME2(6) NULL,
        [ChangeByUser]          VARCHAR(30)  NULL,
        [DateChange]          DATETIME2(6) NULL,
        [ActiveRecord]         CHAR(1)      NULL,
        [ExtendedCode]  CHAR(2)      NULL    --varchar
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/Pricing_AFI/FreightClass/GBL_Sales_tblFreightClass.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


