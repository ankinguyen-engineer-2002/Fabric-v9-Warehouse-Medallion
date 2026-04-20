CREATE TABLE [Marketing].[WarRoomCountryCodes]
    (
        [ItemSKU]     VARCHAR(15)  NULL,
        [CountryCode] CHAR(2)      NULL,
        [DefaultCode] BIT          NULL,
        [AddedByUser]        VARCHAR(30)  NULL,
        [DateAdded]        DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]        VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL, --DATETIME2 (7) NULL,
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/WarRoomCountryCodes/AFI_Sales_tblWarRmCountryCodes.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
