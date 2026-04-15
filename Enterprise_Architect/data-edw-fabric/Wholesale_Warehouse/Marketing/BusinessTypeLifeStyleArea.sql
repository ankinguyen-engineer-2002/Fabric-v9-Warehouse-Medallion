CREATE TABLE [Marketing].[BusinessTypeLifeStyleArea]
    (
        [SeriesCode]       VARCHAR(16)  NULL,
        [BusinessTypeCode] CHAR(2)      NULL,
        [LifeStyleAreaID]  INT          NULL,
        [AddedByUser]             VARCHAR(30)  NULL,
        [DateAdded]             DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]             VARCHAR(30)  NULL,
        [DateChange]             DATETIME2(6) NULL  --- DATETIME2(6)
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/BusinessTypeLifeStyleArea/GBL_Sales_tblBusinessTypeLifeStyleArea.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
