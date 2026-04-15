CREATE TABLE [ProductKnowledge].[ItemClass]
    (
        [ItemClass]          CHAR(4)      NULL,
        [ItemClassName]      VARCHAR(25)  NULL,
        [ImportDomesticFlag] CHAR(1)      NULL,
        [ProductLine]        CHAR(2)      NULL,
        [SalesCategory]      CHAR(3)      NULL,
        [DivsionCode]        CHAR(1)      NULL,
        [RetailCategory]     CHAR(3)      NULL,
        [FinancialDivision]  CHAR(1)      NULL,
        [AddedByUser]               VARCHAR(30)  NULL,
        [DateAdded]               DATETIME2(6) NULL,
        [ChangeByUser]               VARCHAR(30)  NULL,
        [DateChange]               DATETIME2(6) NULL,
        [ActiveRecord]              CHAR(1)      NULL
    );
--DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/MasterData/ProductKnowledge/ItemClass/GBL_ProductKnowledge_tblItemClass.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],
