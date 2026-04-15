CREATE TABLE GeographicData.CountryMaster
    (
        [Country]                  CHAR(3)      NULL,
        [Description]              VARCHAR(30)  NULL,
        [TerritoryCode]            CHAR(5)      NULL,
        [EscheduleSession]         VARCHAR(100) NULL,
        [DescartesCntryCd]         CHAR(2)      NULL,
        [RouteZone]                VARCHAR(3)   NULL,
        [AddedByUser]              VARCHAR(30)  NULL,
        [DateAdded]                DATETIME2(6) NULL, --Datetime2(7)
        [ChangeByUser]             VARCHAR(30)  NULL,
        [DateChange]               DATETIME2(6) NULL, --Datetime2(7)
        [ActiveRecord]             CHAR(1)      NULL,
        [CurrencyCode]             CHAR(3)      NULL,
        [CountryOfOriginShipLabel] INT          NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--   LOCATION = N'/MasterData/GeographicData/CountryMaster/GBL_Sales_tblCountryMaster.snappy.parquet',
--   FILE_FORMAT = [ParquetFileFormatSnappy],

