CREATE TABLE [MasterData_Retail_Wrk].[GLPost_References] (

	[Operation] char(3) NULL, 
	[GLPostID] varchar(50) NULL, 
	[FisYear] int NULL, 
	[SourceID] varchar(50) NULL, 
	[RecStatus] char(5) NULL, 
	[Position] int NULL, 
	[ReferenceType] varchar(50) NULL, 
	[ReferenceKey] varchar(50) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateChanged] datetime2(6) NULL
);