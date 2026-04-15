CREATE TABLE [Pricing_AFI].[FreightRates]
    (
        [FreightCode]    CHAR(3)        NULL,
        [Warehouse]      CHAR(3)        NULL,
        [FreightClass]   CHAR(2)        NULL,
        [FreightDollars] DECIMAL(8, 2)  NULL,
        [FreightPercent] DECIMAL(3, 3)  NULL,
        [BaseCodeFlag]   CHAR(1)        NULL,
        [FromValue]      DECIMAL(12, 3) NULL,
        [ToValue]        DECIMAL(12, 3) NULL,
        [Minimum]        DECIMAL(12, 2) NULL,
        [FreightZone]    CHAR(5)        NULL,
        [Sequence]       CHAR(4)        NULL,
        [StartDate]      DATE           NULL,  --DATETIME2
        [EndDate]        DATE           NULL,  --DATETIME2
        [AuditFlag]      BIT            NULL,
        [AddedByUser]           VARCHAR(30)    NULL,
        [DateAdded]           DATETIME2(6)   NULL,
        [ChangeByUser]           VARCHAR(30)    NULL,
        [DateChange]           DATETIME2(6)   NULL,
        [ActiveRecord]          CHAR(1)        NULL
    );

--   DATA_SOURCE = [AzureStorageGen2a],
--    LOCATION = N'/Wholesale/Pricing_AFI/FreightRates/AFI_Sales_tblFreightRates.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

