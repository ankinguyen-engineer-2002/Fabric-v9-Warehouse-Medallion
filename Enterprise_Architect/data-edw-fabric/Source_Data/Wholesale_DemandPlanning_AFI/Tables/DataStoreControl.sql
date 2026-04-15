CREATE TABLE [Wholesale_DemandPlanning_AFI].[DataStoreControl] (

	[dscDataStoreName] varchar(50) NOT NULL, 
	[dscTableName] varchar(50) NOT NULL, 
	[dscLastRefresh] datetime2(6) NULL, 
	[dscUpdating] bit NOT NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL
);