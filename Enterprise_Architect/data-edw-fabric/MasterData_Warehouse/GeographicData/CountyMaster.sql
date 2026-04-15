CREATE TABLE GeographicData.CountyMaster
    (
        [CountyCode]        CHAR(3)      NULL,
        [TerritoryCode]     CHAR(5)      NULL,
        [State]             CHAR(2)      NULL,
        [County]            VARCHAR(25)  NULL,
        [Census]            INT          NULL,
        [Routezone]         CHAR(3)      NULL,
        [MSA_FIPS]          CHAR(4)      NULL,
        [Country]           CHAR(3)      NULL,
        [AddedByUser]       VARCHAR(30)  NULL,
        [DateAdded]         DATETIME2(6) NULL, --Datetime2(7)
        [ChangeByUser]      VARCHAR(30)  NULL,
        [DateChange]        DATETIME2(6) NULL, --Datetime2(7)
        [ActiveRecord]      CHAR(1)      NULL,
        [ResponsibleRegion] CHAR(3)      NULL,
        [CountyFips]        CHAR(5)      NULL,
        [DMAName]           VARCHAR(40)  NULL,
        [CBSAName]          VARCHAR(50)  NULL,
        [CBSACode]          CHAR(5)      NULL,
        [CBSAType]          CHAR(5)      NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/MasterData/GeographicData/CountyMaster/GBL_Sales_tblCountyMaster.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],


