CREATE TABLE [Retail_External].[ScoreboardSalesPerson] (

	[Operation] varchar(15) NOT NULL, 
	[ID] int NOT NULL, 
	[StorisID] varchar(50) NOT NULL, 
	[CompanyID] int NOT NULL, 
	[Name] varchar(50) NOT NULL, 
	[HomeStoreID] int NOT NULL, 
	[ChangedDate] datetime2(6) NULL, 
	[ChangedBy] varchar(50) NULL, 
	[DeletedIND] bit NOT NULL, 
	[PasswordHash] varchar(64) NULL, 
	[PasswordLastHashed] datetime2(6) NULL, 
	[HouseCompanyIND] bit NOT NULL
);