CREATE TABLE [Retail_Corporate].[GLSource] (

	[Operation] char(3) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(512) NULL, 
	[GLSourceID] varchar(50) NOT NULL, 
	[LastBatchID] int NULL, 
	[RecStatus] char(5) NULL, 
	[SourceID] varchar(50) NULL
);