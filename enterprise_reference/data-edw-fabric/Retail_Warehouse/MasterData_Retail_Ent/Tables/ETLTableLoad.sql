CREATE TABLE [MasterData_Retail_Ent].[ETLTableLoad] (

	[ID] bigint NULL, 
	[SourceDataBase] varchar(100) NULL, 
	[SourceSchema] varchar(100) NULL, 
	[TargetDataBase] varchar(100) NULL, 
	[TargetSchema] varchar(100) NULL, 
	[TableName] varchar(100) NULL, 
	[JoinColumn] varchar(100) NULL, 
	[Filter1] varchar(100) NULL, 
	[Filter2] varchar(100) NULL, 
	[IsActive] bit NULL, 
	[Frequency] int NULL
);