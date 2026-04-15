CREATE TABLE [ProductKnowledge].[SeriesGroupingLookup]
    (
        [LookupID]        SMALLINT     NULL,
        [LookupCode]      VARCHAR(35)  NULL,
        [HiPrPoint]       DECIMAL(5)   NULL,
        [LoPrPoint]       DECIMAL(5)   NULL,
        [PrIncr]          DECIMAL(5)   NULL,
        [PlCode]          CHAR(2)      NULL,
        [Sort]            SMALLINT     NULL,
        [Icon]            VARCHAR(30)  NULL,
        [FeaturedProduct] VARCHAR(100) NULL,
        [PriceBkld]       SMALLINT     NULL,
        [PriceBkCode]     VARCHAR(35)  NULL,
        [PrPointType]     CHAR(1)      NULL,
        [AddedByUser]            VARCHAR(30)  NULL,
        [DateAdded]            DATETIME2(6) NULL,
        [ChangeByUser]            VARCHAR(30)  NULL,
        [DateChange]            DATETIME2(6) NULL,
        [ActiveRecord]           CHAR(1)      NULL,
        [ItemSKU]         VARCHAR(15)  NULL,
        [Margin]          SMALLINT     NULL,
        [PriceBookSort]   SMALLINT     NULL,
        [RoomLocation]    INT          NULL,
        [AssociationCode] VARCHAR(35)  NULL
    );

--  DATA_SOURCE = [AzureStorageGen2a],
--  LOCATION = N'/MasterData/ProductKnowledge/SeriesGroupingLookup/GBL_ProductKnowledge_tblSeriesGroupingLookup.snappy.parquet',
--  FILE_FORMAT = [ParquetFileFormatSnappy],


