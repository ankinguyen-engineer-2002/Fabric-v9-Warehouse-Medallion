CREATE TABLE [Marketing].[SetDetailCustom]
    (
        [CustomerNumber] CHAR(8)      NOT NULL,
        [SetNumber]      VARCHAR(15)  NOT NULL,
        [ItemNumber]     VARCHAR(15)  NOT NULL,
        [Qty]            DECIMAL(3)   NOT NULL,
        [Key]            BIT          NOT NULL,
        [AddedByUser]           VARCHAR(30)  NULL,
        [DateAdded]           DATETIME2(6) NULL, --DATETIME2 (7) NULL,
        [ChangeByUser]           VARCHAR(30)  NULL,
        [DateChange]           DATETIME2(6) NULL  --DATETIME2 (7) NULL,
    );


-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION =  N'/Wholesale/Marketing/SetDetailCustom/AFI_Sales_tblSetDetailCustom.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
