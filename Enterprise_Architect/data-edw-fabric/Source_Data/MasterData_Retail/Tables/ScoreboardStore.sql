CREATE TABLE [MasterData_Retail].[ScoreboardStore] (

	[StoreID] int NOT NULL, 
	[StoreName] varchar(100) NULL, 
	[StoreNumber] varchar(10) NULL, 
	[OpenTimeToday] varchar(50) NULL, 
	[ClosedTimeToday] varchar(50) NULL, 
	[isActive] bit NOT NULL
);