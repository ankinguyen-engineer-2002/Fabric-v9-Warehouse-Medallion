CREATE TABLE [Retail_External].[LocationGroups-Clone] (

	[Operation] varchar(10) NULL, 
	[LocationID] varchar(20) NULL, 
	[LocationGroupID] varchar(20) NULL, 
	[PrimaryLocationGroupID] varchar(10) NULL, 
	[Active] int NULL, 
	[DateModified] datetime2(6) NULL, 
	[Comment] varchar(250) NULL
);