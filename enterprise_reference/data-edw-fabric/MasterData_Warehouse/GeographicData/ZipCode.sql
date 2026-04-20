CREATE TABLE GeographicData.ZipCode
    (
        [Zipcode]         VARCHAR(5)    NOT NULL,
        [State]           VARCHAR(2)    NOT NULL,
        [CityName]        VARCHAR(25)   NOT NULL,
        [CityAbrev]       VARCHAR(10)   NOT NULL,
        [County]          VARCHAR(3)    NOT NULL,
        [Country]         VARCHAR(3)    NOT NULL,
        [MSA]             VARCHAR(4)    NOT NULL,
        [TimeZoneCode]    VARCHAR(5)    NOT NULL,
        [DayLightSavings] CHAR(1)       NOT NULL,
        [Latitude]        DECIMAL(7, 4) NOT NULL,
        [Long]            DECIMAL(8, 4) NOT NULL,
        [AddedByUser]     VARCHAR(30)   NULL,
        [DateAdded]       DATETIME2(6)  NULL, --Datetime
        [ChangeByUser]    VARCHAR(30)   NULL,
        [DateChange]      DATETIME2(6)  NULL, --Datetime
        [ActiveRecord]    VARCHAR(1)    NULL,
        [Preferred]       BIT           NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/MasterData/GeographicData/ZipCode/GBL_Sales_tblZipCode.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


