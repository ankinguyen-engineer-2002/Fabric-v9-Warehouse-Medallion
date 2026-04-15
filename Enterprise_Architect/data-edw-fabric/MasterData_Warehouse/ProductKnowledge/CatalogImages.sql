CREATE TABLE [ProductKnowledge].[CatalogImages]
    (
        [SeriesCode]   VARCHAR(16)  NOT NULL,
        [ImageType]    VARCHAR(10)  NOT NULL,
        [ImageName]    VARCHAR(50)  NOT NULL,
        [MasterImage]  BIT          NOT NULL,
        [AddedByUser]         VARCHAR(30)  NULL,
        [DateAdded]         DATETIME2(6) NULL,
        [ChangeByUser]         VARCHAR(30)  NULL,
        [DateChange]         DATETIME2(6) NULL,
        [ActiveRecord]        CHAR(1)      NOT NULL
    );

--DATA_SOURCE = [AzureStorageGen2a],
--LOCATION = N'/MasterData/ProductKnowledge/CatalogImages/GBL_ProductKnowledge_tblCatalogImages.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],
