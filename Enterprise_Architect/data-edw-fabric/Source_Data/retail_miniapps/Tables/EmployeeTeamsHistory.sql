CREATE TABLE [Retail_Miniapps].[EmployeeTeamsHistory] (

	[operation] varchar(8000) NULL, 
	[ID] int NULL, 
	[EmployeeID] int NULL, 
	[Team] varchar(100) NULL, 
	[PositionID] int NULL, 
	[StoreID] varchar(100) NULL, 
	[ActiveStatus] bit NULL, 
	[EntryStartDate] datetime2(6) NULL, 
	[SalespersonID] varchar(100) NULL
);