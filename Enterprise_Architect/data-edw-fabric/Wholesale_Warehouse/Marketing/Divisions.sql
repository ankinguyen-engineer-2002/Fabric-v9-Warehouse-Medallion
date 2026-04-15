CREATE TABLE [Marketing].[Divisions]
    (
        [DivisionCode]      CHAR(1)      NULL,
        [Description]       VARCHAR(25)  NULL,
        [ISDescription]     VARCHAR(25)  NULL,
        [President]         VARCHAR(25)  NULL,
        [DefaultSalesClass] CHAR(2)      NULL,
        [MHS_Name]          CHAR(8)      NULL,
        [OtherRegionCode]   CHAR(3)      NULL,
        [Repid]             CHAR(5)      NULL,
        [ItemSKU]           VARCHAR(15)  NULL,
        [ItemDescription]             VARCHAR(30)  NULL,
        [Itseq]             CHAR(7)      NULL,
        [Grpdsc]            VARCHAR(15)  NULL,
        [AddedByUser]              VARCHAR(30)  NULL,
        [DateAdded]              DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]              VARCHAR(30)  NULL,
        [DateChange]              DATETIME2(6) NULL, --- DATETIME2(6)
        [ActiveRecord]             CHAR(1)      NULL,
        [Companion]         CHAR(6)      NULL,
        [CRMcode]           INT          NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =   N'/Wholesale/Marketing/isions/GBL_Sales_tblisions.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
