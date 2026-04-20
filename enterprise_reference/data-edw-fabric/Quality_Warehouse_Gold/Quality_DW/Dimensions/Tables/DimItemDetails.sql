CREATE TABLE [Quality_DW].[DimItemDetails]
    (
        [ItemNo]                    VARCHAR(15)   NULL,
        [DelvInPkg]                 CHAR(7)       NOT NULL,
        [ipcItemNumber]             VARCHAR(15)   NULL,
        [ipcId]                     INT           NULL,
        [eldLookupValueDescription] VARCHAR(8000) NULL,
        [AshleyExpFlag]             CHAR(1)       NULL,
        [AddedByUser]                      VARCHAR(30)   NULL,
        [DateAdded]                      DATETIME2(6)  NULL, --Datetime
        [ChangeByUser]                      VARCHAR(30)   NULL,
        [DateChange]                      DATETIME2(6)  NULL  --Datetime
    );

 GO
    
CREATE STATISTICS [Stat_DimItemDetails_ItemNo]
    ON Quality_DW.DimItemDetails
    (
        [ItemNo]
    );

GO
CREATE STATISTICS [Stat_DimItemDetails_DelvInPkg]
    ON Quality_DW.DimItemDetails
    (
        DelvInPkg
    );

GO
CREATE STATISTICS [Stat_DimItemDetails_ipcId]
    ON Quality_DW.DimItemDetails
    (
        ipcId
    );

GO