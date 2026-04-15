CREATE TABLE [ProductKnowledge].[ItemCollectiveClass]
    (
        [ItemClass]       CHAR(4)     NOT NULL,
        [CollectiveClass] INT         NOT NULL,
        [Description]     VARCHAR(50) NULL
    );

--LOCATION = N'/MasterData/ProductKnowledge/ItemCollectiveClass/GBL_ProductKnowledge_tblItemCollectiveClass.snappy.parquet',
--FILE_FORMAT = [ParquetFileFormatSnappy],
--REJECT_TYPE = VALUE,

