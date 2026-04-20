CREATE TABLE [DW_Developer].[TableDictionary] (
    [ServerName]                         VARCHAR (50)   NOT NULL, -- CONSTRAINT [DF_TableDictionary_ServerName2] DEFAULT ('EDW-Fabric') NOT NULL,
    [DatabaseName]                       VARCHAR (50)   NOT NULL,
    [SchemaName]                         VARCHAR (100)  NULL,
    [TableName]                          VARCHAR (100)  NOT NULL,
    [ObjectType]                         VARCHAR (20)   NULL,
    [PrimaryKey]                         VARCHAR (700)  NULL,
    [AlternateKey]                       VARCHAR (500)  NULL,
    [StorageType]                        VARCHAR (25)   NULL,
    [RowSToreClusteredKey]               VARCHAR (750)  NULL,
    [AdditionalIndexes]                  VARCHAR (500)  NULL,
    [DistributionKey]                    VARCHAR (500)  NULL,
    [IndexType]                          VARCHAR (25)   NULL,
    [SourceSystem]                       VARCHAR (100)  NULL,
    [SourceServer]                       VARCHAR (100)  NULL,
    [SourceDatabase]                     VARCHAR (200)  NULL,
    [SourceObject]                       VARCHAR (400)  NULL,
    [SourceObjectAlias]                  VARCHAR (100)  NULL,
    [SourcePlatform]                     VARCHAR (100)  NULL,
    [ReplicatedSource]                   VARCHAR (500)  NULL,
    [ETLTool]                            VARCHAR (50)   NULL,
    [PackageName]                        VARCHAR (400)  NULL,
    [TFSPath]                            VARCHAR (400)  NULL,
    [JobName]                            VARCHAR (100)  NULL,
    [JobServer]                          VARCHAR (50)   NULL,
    [RefreshRate]                        INT            NULL,
    [RefreshDescription]                 VARCHAR (500)  NULL,
    [UpdateMethod]                       VARCHAR (20)   NULL,
    [ExtractQuery]                       VARCHAR (8000) NULL,
    [UpdateQuery]                        VARCHAR (8000) NULL,
    [AdditionaNotes]                     VARCHAR (500)  NULL,
    [InvalidCount]                       DECIMAL (12)   NULL,
    [RowCount]                           DECIMAL (12)   NULL,
    [CreateDate]                         DATETIME2 (6)  NULL,
    [Modified]                           DATETIME2 (6)  NULL,
    [CreatedBy]                          VARCHAR (100)  NULL,
    [ModifiedBy]                         VARCHAR (100)  NULL,
    [LastAudit]                          DATETIME2 (6)  NULL,
    [ErrorMsg]                           VARCHAR (500)  NULL,
    [CreatedDate]                        DATETIME2 (6)  NULL,
    [Created]                            DATETIME2 (6)  NULL,
    [SourceObjectType]                   VARCHAR (15)   NULL,
    [PartitionKey]                       VARCHAR (200)  NULL,
    [ColumnStatsCount]                   INT            NULL,
    [ColumnCount]                        INT            NULL,
    [ColumnStatsLastUpdated]             DATETIME2 (6)  NULL,
    [DeletedRows]                        DECIMAL (12)   NULL,
    [DataLake]                           VARCHAR (250)  NULL,
    [DataLakeFolder]                     VARCHAR (500)  NULL,
    [DataLakeFolderArchive]              VARCHAR (500)  NULL,
    [ReplicatedSourceExpiryHours]        INT            NULL,
    [ReplicatedSourceArchiveExpiryHours] INT            NULL,
    [StageDataLakeFolder]                VARCHAR (500)  NULL,
    [LastBatchStartDate]                 DATETIME2 (6)  NULL,
    [LibraryList]                        VARCHAR (500)  NULL,
    [DateKey]                            VARCHAR (100)  NULL,
    [DateRangeDays]                      INT            NULL,
    [OperationKey]                       VARCHAR (100)  NULL,
    [PII]                                VARCHAR (8000)  NULL,
    [ValidKeyValues]                     BIT            NULL,
    [SelectColumn]                       VARCHAR (8000)  NULL,
    [DataBricksClusterVersion]           VARCHAR (30)   NULL,
    [DataBricksNodeType]                 VARCHAR (30)   NULL,
    [DataBricksClusterRange]             VARCHAR (10)   NULL
)





GO
CREATE STATISTICS [Stat_TableDictionary_ValidKeyValues]
    ON [DW_Developer].[TableDictionary]([ValidKeyValues]);


GO
CREATE STATISTICS [Stat_TableDictionary_UpdateQuery]
    ON [DW_Developer].[TableDictionary]([UpdateQuery]);


GO
CREATE STATISTICS [Stat_TableDictionary_TableName]
    ON [DW_Developer].[TableDictionary]([TableName]);


GO
CREATE STATISTICS [Stat_TableDictionary_StorageType]
    ON [DW_Developer].[TableDictionary]([StorageType]);


GO
CREATE STATISTICS [Stat_TableDictionary_StageDataLakeFolder]
    ON [DW_Developer].[TableDictionary]([StageDataLakeFolder]);


GO
CREATE STATISTICS [Stat_TableDictionary_SourcePlatform]
    ON [DW_Developer].[TableDictionary]([SourcePlatform]);


GO
CREATE STATISTICS [Stat_TableDictionary_SourceDatabase]
    ON [DW_Developer].[TableDictionary]([SourceDatabase]);


GO
CREATE STATISTICS [Stat_TableDictionary_ServerName]
    ON [DW_Developer].[TableDictionary]([ServerName]);


GO
CREATE STATISTICS [Stat_TableDictionary_SchemaName]
    ON [DW_Developer].[TableDictionary]([SchemaName]);


GO
CREATE STATISTICS [Stat_TableDictionary_ReplicatedSource]
    ON [DW_Developer].[TableDictionary]([ReplicatedSource]);


GO
CREATE STATISTICS [Stat_TableDictionary_RefreshRate]
    ON [DW_Developer].[TableDictionary]([RefreshRate]);


GO
CREATE STATISTICS [Stat_TableDictionary_PrimaryKey]
    ON [DW_Developer].[TableDictionary]([PrimaryKey]);


GO
CREATE STATISTICS [Stat_TableDictionary_PartitionKey]
    ON [DW_Developer].[TableDictionary]([PartitionKey]);


GO
CREATE STATISTICS [Stat_TableDictionary_ObjectType]
    ON [DW_Developer].[TableDictionary]([ObjectType]);


GO
CREATE STATISTICS [Stat_TableDictionary_Modified]
    ON [DW_Developer].[TableDictionary]([Modified]);


GO
CREATE STATISTICS [Stat_TableDictionary_LibraryList]
    ON [DW_Developer].[TableDictionary]([LibraryList]);


GO
CREATE STATISTICS [Stat_TableDictionary_LastBatchStartDate]
    ON [DW_Developer].[TableDictionary]([LastBatchStartDate]);


GO
CREATE STATISTICS [Stat_TableDictionary_JobServer]
    ON [DW_Developer].[TableDictionary]([JobServer]);


GO
CREATE STATISTICS [Stat_TableDictionary_JobName]
    ON [DW_Developer].[TableDictionary]([JobName]);


GO
CREATE STATISTICS [Stat_TableDictionary_InvalidCount]
    ON [DW_Developer].[TableDictionary]([InvalidCount]);


GO
CREATE STATISTICS [Stat_TableDictionary_IndexType]
    ON [DW_Developer].[TableDictionary]([IndexType]);


GO
CREATE STATISTICS [Stat_TableDictionary_ETLTool]
    ON [DW_Developer].[TableDictionary]([ETLTool]);


GO
CREATE STATISTICS [Stat_TableDictionary_ErrorMsg]
    ON [DW_Developer].[TableDictionary]([ErrorMsg]);


GO
CREATE STATISTICS [Stat_TableDictionary_DistributionKey]
    ON [DW_Developer].[TableDictionary]([DistributionKey]);


GO
CREATE STATISTICS [Stat_TableDictionary_DateRangeDays]
    ON [DW_Developer].[TableDictionary]([DateRangeDays]);


GO
CREATE STATISTICS [Stat_TableDictionary_DataLakeFolder]
    ON [DW_Developer].[TableDictionary]([DataLakeFolder]);


GO
CREATE STATISTICS [Stat_TableDictionary_DataLake]
    ON [DW_Developer].[TableDictionary]([DataLake]);


GO
CREATE STATISTICS [Stat_TableDictionary_DatabaseName]
    ON [DW_Developer].[TableDictionary]([DatabaseName]);


GO
CREATE STATISTICS [Stat_TableDictionary_CreateDate]
    ON [DW_Developer].[TableDictionary]([CreateDate]);


GO
CREATE STATISTICS [Stat_TableDictionary_Created]
    ON [DW_Developer].[TableDictionary]([Created]);


GO
CREATE STATISTICS [Stat_TableDictionary_ColumnStatsCount]
    ON [DW_Developer].[TableDictionary]([ColumnStatsCount]);


GO
CREATE STATISTICS [Stat_TableDictionary_ColumnCount]
    ON [DW_Developer].[TableDictionary]([ColumnCount]);


GO
CREATE STATISTICS [Stat_TableDictionary_AdditionaNotes]
    ON [DW_Developer].[TableDictionary]([AdditionaNotes]);


GO
CREATE STATISTICS [Stat_TableDictionary_UpdateMethod]
    ON [DW_Developer].[TableDictionary]([UpdateMethod]);


GO
CREATE STATISTICS [Stat_TableDictionary_TFSPath]
    ON [DW_Developer].[TableDictionary]([TFSPath]);


GO
CREATE STATISTICS [Stat_TableDictionary_SourceSystem]
    ON [DW_Developer].[TableDictionary]([SourceSystem]);


GO
CREATE STATISTICS [Stat_TableDictionary_SourceServer]
    ON [DW_Developer].[TableDictionary]([SourceServer]);


GO
CREATE STATISTICS [Stat_TableDictionary_SourceObjectType]
    ON [DW_Developer].[TableDictionary]([SourceObjectType]);


GO
CREATE STATISTICS [Stat_TableDictionary_SourceObjectAlias]
    ON [DW_Developer].[TableDictionary]([SourceObjectAlias]);


GO
CREATE STATISTICS [Stat_TableDictionary_SourceObject]
    ON [DW_Developer].[TableDictionary]([SourceObject]);



GO
CREATE STATISTICS [Stat_TableDictionary_RowSToreClusteredKey]
    ON [DW_Developer].[TableDictionary]([RowSToreClusteredKey]);


GO
CREATE STATISTICS [Stat_TableDictionary_RowCount]
    ON [DW_Developer].[TableDictionary]([RowCount]);


GO
CREATE STATISTICS [Stat_TableDictionary_ReplicatedSourceExpiryHours]
    ON [DW_Developer].[TableDictionary]([ReplicatedSourceExpiryHours]);


GO
CREATE STATISTICS [Stat_TableDictionary_ReplicatedSourceArchiveExpiryHours]
    ON [DW_Developer].[TableDictionary]([ReplicatedSourceArchiveExpiryHours]);


GO
CREATE STATISTICS [Stat_TableDictionary_RefreshDescription]
    ON [DW_Developer].[TableDictionary]([RefreshDescription]);


GO
CREATE STATISTICS [Stat_TableDictionary_PII]
    ON [DW_Developer].[TableDictionary]([PII]);


GO
CREATE STATISTICS [Stat_TableDictionary_PackageName]
    ON [DW_Developer].[TableDictionary]([PackageName]);


GO
CREATE STATISTICS [Stat_TableDictionary_OperationKey]
    ON [DW_Developer].[TableDictionary]([OperationKey]);


GO
CREATE STATISTICS [Stat_TableDictionary_ModifiedBy]
    ON [DW_Developer].[TableDictionary]([ModifiedBy]);


GO
CREATE STATISTICS [Stat_TableDictionary_LastAudit]
    ON [DW_Developer].[TableDictionary]([LastAudit]);


GO
CREATE STATISTICS [Stat_TableDictionary_ExtractQuery]
    ON [DW_Developer].[TableDictionary]([ExtractQuery]);


GO
CREATE STATISTICS [Stat_TableDictionary_DeletedRows]
    ON [DW_Developer].[TableDictionary]([DeletedRows]);


GO
CREATE STATISTICS [Stat_TableDictionary_DateKey]
    ON [DW_Developer].[TableDictionary]([DateKey]);


GO
CREATE STATISTICS [Stat_TableDictionary_DataLakeFolderArchive]
    ON [DW_Developer].[TableDictionary]([DataLakeFolderArchive]);


GO
CREATE STATISTICS [Stat_TableDictionary_CreatedDate]
    ON [DW_Developer].[TableDictionary]([CreatedDate]);


GO
CREATE STATISTICS [Stat_TableDictionary_CreatedBy]
    ON [DW_Developer].[TableDictionary]([CreatedBy]);


GO
CREATE STATISTICS [Stat_TableDictionary_ColumnStatsLastUpdated]
    ON [DW_Developer].[TableDictionary]([ColumnStatsLastUpdated]);


GO
CREATE STATISTICS [Stat_TableDictionary_AlternateKey]
    ON [DW_Developer].[TableDictionary]([AlternateKey]);


GO
CREATE STATISTICS [Stat_TableDictionary_AdditionalIndexes]
    ON [DW_Developer].[TableDictionary]([AdditionalIndexes]);


GO
CREATE STATISTICS [Stat_TableDictionary_DataBricksClusterVersion]
    ON [DW_Developer].[TableDictionary]([DataBricksClusterVersion]);

