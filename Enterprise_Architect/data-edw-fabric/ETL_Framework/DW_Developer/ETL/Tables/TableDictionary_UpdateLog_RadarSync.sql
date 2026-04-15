CREATE TABLE [DW_Developer].[TableDictionary_UpdateLog_RadarSync] (
    [DatabaseName] VARCHAR(100) NOT NULL, 
    [SchemaName]  VARCHAR (100) NOT NULL,
    [TableName]   VARCHAR (100) NOT NULL,
    [LastUpdated] DATETIME2 (6) NOT NULL   --DATETIME
)

GO
CREATE STATISTICS [Stat_TableDictionary_UpdateLog_TableName_RadarSync]
    ON [DW_Developer].[TableDictionary_UpdateLog]([TableName]);


GO
CREATE STATISTICS [Stat_TableDictionary_UpdateLog_LastUpdated_RadarSync]
    ON [DW_Developer].[TableDictionary_UpdateLog]([LastUpdated]);


GO
CREATE STATISTICS [Stat_TableDictionary_UpdateLog_SchemaName_RadarSync]
    ON [DW_Developer].[TableDictionary_UpdateLog]([SchemaName]);


