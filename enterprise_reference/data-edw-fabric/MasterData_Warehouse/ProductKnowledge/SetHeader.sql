CREATE TABLE [ProductKnowledge].[SetHeader]
    (
        [CustomerNumber] CHAR(8)       NULL,
        [SetNumber]      VARCHAR(15)   NULL,
        [SetName]        VARCHAR(60)   NULL,
        [Cost]           DECIMAL(7, 2) NULL,
        [GroupCode]      CHAR(6)       NULL,
        [Active]         BIT           NULL,
        [option]         BIT           NULL,
        [AfterSeries]    VARCHAR(16)   NULL,
        [TemplateID]     VARCHAR(15)   NULL,
        [SetImage]       VARCHAR(60)   NULL,
        [PricePointPkg]  INT       NULL,
        [AddedByUser]           VARCHAR(30)   NULL,
        [DateAdded]           DATETIME2(6)  NULL, --DateTime2(7)
        [ChangeByUser]           VARCHAR(30)   NULL,
        [DateChange]           DATETIME2(6)  NULL  --DateTime2(7)
    );
--  DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/MasterData/ProductKnowledge/SetHeader/GBL_ProductKnowledge_tblSetHeader.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],


