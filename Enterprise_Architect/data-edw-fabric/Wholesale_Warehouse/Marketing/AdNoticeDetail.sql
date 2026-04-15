CREATE TABLE [Marketing].[AdNoticeDetail]
    (
        [Key]          INT          NOT NULL,
        [ForeignKey]   INT          NOT NULL,
        [ItemSKU]      VARCHAR(15)  NOT NULL,
        [Quantity]     INT          NOT NULL,
        [AddedByUser]         VARCHAR(30)  NULL,
        [DateAdded]         DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]         VARCHAR(30)  NULL,
        [DateChange]         DATETIME2(6) NULL, --- DATETIME2(6)
        [Warehouse]    CHAR(3)      NOT NULL,
        [Approved]     BIT          NOT NULL,
        [Comments]     VARCHAR(500) NOT NULL,
        [ChangeNeeded] BIT          NOT NULL,
        [QtyAvailable] INT          NULL,
        [ATPDate]      DATETIME2(6) NULL, --- DATETIME2(6)
        [PreviousQty]  INT          NULL,
        [DPResponded]  BIT          NOT NULL
    );

-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/AdNotice/AFI_Sales_tblAdNotice.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],