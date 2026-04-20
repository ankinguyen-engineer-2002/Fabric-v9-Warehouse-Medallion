CREATE TABLE GeographicData.StateMaster
    (
        [State]         CHAR(2)      NULL,
        [Description]   VARCHAR(25)  NULL,
        [Country]       CHAR(3)      NULL,
        [TerritoryCode] CHAR(5)      NULL,
        [State_FIPS]    CHAR(2)      NULL,
        [AddedByUser]   VARCHAR(30)  NULL,
        [DateAdded]     DATETIME2(6) NULL,   --Datetime2(7)
        [ChangeByUser]  VARCHAR(30)  NULL,
        [DateChange]    DATETIME2(6) NULL,   --Datetime2(7)
        [ActiveRecord]  CHAR(1)      NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/MasterData/GeographicData/StateMaster/GBL_Sales_tblStateMaster.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],

