CREATE TABLE [Transportation].[TripReprintCodes]
    (
        [ReasonCode]       CHAR(2)     NOT NULL,
        [Description]      VARCHAR(30) NULL,
        [ReasonCodeStatus] CHAR(15)    NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Wholesale/CODIS/DWBOLRC/AFI_Codis_DWBOLRC.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],

