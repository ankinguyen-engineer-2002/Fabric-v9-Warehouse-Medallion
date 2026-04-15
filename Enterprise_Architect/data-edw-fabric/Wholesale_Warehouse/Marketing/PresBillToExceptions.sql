CREATE TABLE [Marketing].[PresBillToExceptions] (
    [CustomerNumber] CHAR (8)      NULL,
    [ActiveRecord]          CHAR (1)      NULL,
    [AddedByUser]           VARCHAR (30)  NULL,
    [DateAdded]           DATETIME2 (6) NULL,   --DATETIME2 (7) NULL,
    [ChangeByUser]           VARCHAR (30)  NULL,
    [DateChange]           DATETIME2 (6) NULL   --DATETIME2 (7) NULL,
)


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/MrktSpclstRegion/GBL_Sales_tblMrktSpclstRegion.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
