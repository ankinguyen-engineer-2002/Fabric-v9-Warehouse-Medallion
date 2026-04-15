CREATE TABLE [Retail_External].[ScoreboardStore] (

	[Operation] varchar(15) NOT NULL, 
	[ID] int NOT NULL, 
	[StorisID] varchar(50) NOT NULL, 
	[CompanyID] int NOT NULL, 
	[Name] varchar(50) NOT NULL, 
	[ChangedDate] datetime2(6) NULL, 
	[ChangedBy] varchar(50) NULL
);