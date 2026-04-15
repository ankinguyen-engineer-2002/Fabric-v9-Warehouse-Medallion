CREATE TABLE [MasterData_Retail_Ent_Wrk].[Config] (

	[RowNum] int NULL, 
	[ConfigID] int NULL, 
	[SourceDB] varchar(128) NULL, 
	[SourceSchema] varchar(128) NULL, 
	[TargetDB] varchar(128) NULL, 
	[TargetSchema] varchar(128) NULL, 
	[TableName] varchar(128) NULL, 
	[JoinColumn] varchar(128) NULL, 
	[Filter1] varchar(500) NULL, 
	[Filter2] varchar(500) NULL, 
	[Frequency] int NULL
);