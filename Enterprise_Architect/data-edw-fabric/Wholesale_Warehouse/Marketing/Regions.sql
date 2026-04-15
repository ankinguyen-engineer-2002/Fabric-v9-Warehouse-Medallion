CREATE TABLE [Marketing].[Regions]
    (
        [RegionCode]        CHAR(3)      NULL,
        [Description]       VARCHAR(25)  NULL,
        [Division]          CHAR(1)      NULL,
        [VPDesc]            VARCHAR(25)  NULL,
        [RepID]             CHAR(5)      NULL,
        [MHS_Name]          CHAR(8)      NULL,
        [RegionType]        VARCHAR(15)  NULL,
        [AddedByUser]              VARCHAR(30)  NULL,
        [DateAdded]              DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]              VARCHAR(30)  NULL,
        [DateChange]              DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ActiveRecord]             CHAR(1)      NULL,
        [AlternateDivision] CHAR(1)      NULL,
        [CRMcode]           INT          NULL,
        [LastUpdateDate]    DATETIME2(6) NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/ions/GBL_Sales_tblions.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
