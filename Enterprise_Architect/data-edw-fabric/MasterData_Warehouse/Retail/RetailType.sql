CREATE TABLE [Retail].[RetailType]
    (
        [RetailTypeID]          INT          NULL,
        [RetailTypeDescription] VARCHAR(50)  NULL,
        [AddedByUser]                  VARCHAR(30)  NULL,
        [DateAdded]                  DATETIME2(6) NULL,
        [ChangeByUser]                  VARCHAR(30)  NULL,
        [DateChange]                  DATETIME2(6) NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/Retail/MasterData/RetailType/GBL_Sales_tblretailType.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

