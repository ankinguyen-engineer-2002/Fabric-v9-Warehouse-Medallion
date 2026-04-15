CREATE VIEW [DW_Developer].[SchemaMappings]
  AS select ServerName, DatabaseName,SchemaName,TableName, PrimaryKey, SourceObjectAlias, ObjectType, ReplicatedSource, UpdateQuery 
  from [DW_Developer].[TableDictionary]


