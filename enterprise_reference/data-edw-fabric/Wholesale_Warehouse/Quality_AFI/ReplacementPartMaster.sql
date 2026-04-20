CREATE TABLE [Quality_AFI].[ReplacementPartsMaster]
    (
        [ItemSKU]           VARCHAR(15)   NULL,
        [Part]              VARCHAR(15)   NULL,
        [QtyUsed]           INT           NULL,
        [Description]       VARCHAR(40)   NULL,
        [BasePrice]         DECIMAL(7, 2) NULL,
        [Callout]           CHAR(3)       NULL,
        [Source]            CHAR(2)       NULL,
        [DescSrc]           CHAR(2)       NULL,
        [WarrantyException] BIT           NULL,
        [AddedByUser]              VARCHAR(30)   NULL,
        [DateAdded]              DATETIME2(6)  NULL,
        [ChangeByUser]              VARCHAR(30)   NULL,
        [DateChange]              DATETIME2(6)  NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/Wholesale/Quality_AFI/RPOrderPartsMaster/AFI_Sales_Batch_ReplacementPartsMaster.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
