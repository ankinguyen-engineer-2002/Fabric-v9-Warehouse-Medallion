
CREATE TABLE [Marketing].[AFValueList]
    (
        [ID]               INT          NULL,
        [ValueType]        VARCHAR(25)  NULL,
        [ValueCode]        VARCHAR(50)  NULL,
        [ValueDescription] VARCHAR(100) NULL,
        [ValueDefault]     BIT          NULL,
        [ValueSortOrder]   INT          NULL,
        [AddedByUser]             VARCHAR(30)  NULL,
        [DateAdded]             DATETIME2(6) NULL, --- DATETIME2(6)
        [ChangeByUser]             VARCHAR(30)  NULL,
        [DateChange]             DATETIME2(6) NULL, --- DATETIME2(6)
        [Active]           BIT          NULL,
        [DivisionCode]    VARCHAR(200) NULL
    );
    
-- DATA_SOURCE = [AzureStorageGen2a],
-- LOCATION = N'/Wholesale/Marketing/alueList/AFI_Sales_tblalueList.snappy.parquet',
-- FILE_FORMAT = [ParquetFileFormatSnappy],

