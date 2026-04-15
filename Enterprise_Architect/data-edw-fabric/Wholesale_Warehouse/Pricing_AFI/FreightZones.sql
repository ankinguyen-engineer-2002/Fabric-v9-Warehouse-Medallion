CREATE TABLE [Pricing_AFI].[FreightZones]
    (
        [Country]     CHAR(3)      NULL,
        [State]       CHAR(2)      NULL,
        [ZipCode]     CHAR(5)      NULL,
        [Zipext]      CHAR(4)      NULL,
        [FreightZone] CHAR(5)      NULL,
        [Warehouse]   CHAR(3)      NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL,
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL,
        [ActiveRecord]       CHAR(1)      NULL
    );

--    DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/Wholesale/Pricing_AFI/FreightZones/GBL_Sales_tblFreightZones.snappy.parquet',
--    FILE_FORMAT = [ParquetFileFormatSnappy],

