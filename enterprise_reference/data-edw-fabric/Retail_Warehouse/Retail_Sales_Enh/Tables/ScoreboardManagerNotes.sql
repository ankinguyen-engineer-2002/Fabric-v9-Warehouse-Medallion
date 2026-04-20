CREATE TABLE [Retail_Sales_Enh].[ScoreboardManagerNotes] (

	[Source] varchar(5) NULL, 
	[IsUP] varchar(1) NULL, 
	[StatusName] varchar(100) NULL, 
	[SalesPersonID] varchar(20) NULL, 
	[SalesPersonName] varchar(50) NULL, 
	[StoreID] int NULL, 
	[ScoreboardStoreID] int NULL, 
	[StatusStartDate] date NULL, 
	[StartTime] varchar(8) NULL, 
	[EndTime] varchar(8) NULL, 
	[ManagerNotes] varchar(600) NULL, 
	[IsClosed] varchar(3) NULL, 
	[StrikeCount] int NULL, 
	[IsStrike] int NULL, 
	[IsStrikeOut] int NULL, 
	[ConsecutiveStrikes] varchar(20) NULL, 
	[ConsecutiveStrikeOuts] varchar(20) NULL, 
	[Shot] int NULL, 
	[FinApp] int NULL
);