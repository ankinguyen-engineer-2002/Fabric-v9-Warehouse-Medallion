CREATE TABLE [Retail_Corporate].[OrderSource] (

	[Operation] varchar(15) NULL, 
	[Code] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(50) NULL, 
	[ExcludeFromOrderEntry] bit NULL, 
	[LastBatchID] int NULL, 
	[OrderSourceID] varchar(50) NOT NULL, 
	[RecStatus] varchar(5) NULL, 
	[SourceID] varchar(50) NOT NULL
);