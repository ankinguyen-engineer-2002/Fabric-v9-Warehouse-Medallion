CREATE TABLE GeographicData.MSAMaster
    (
        [FIPS]           CHAR(4)      NULL,
        [Description]    VARCHAR(50)  NULL,
        [AddedByUser]    VARCHAR(30)  NULL,
        [DateAdded]      DATETIME2(6) NULL, --datetime2(7)
        [ChangeByUser]   VARCHAR(30)  NULL,
        [DateChange]     DATETIME2(6) NULL, --datetime2(7)
        [ActiveRecord]   CHAR(1)      NULL
    );


--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/MasterData/GeographicData/MsaMaster/AFI_Sales_tblMsaMaster.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

