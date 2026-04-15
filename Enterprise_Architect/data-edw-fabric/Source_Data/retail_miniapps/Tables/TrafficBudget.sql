CREATE TABLE [Retail_Miniapps].[TrafficBudget] (

	[LocationID] varchar(100) NULL, 
	[TransDate] datetime2(6) NULL, 
	[TUGoal] decimal(18,4) NULL, 
	[CloseGoal] decimal(38,9) NULL, 
	[RUGoal] decimal(38,9) NULL, 
	[YearMonthKey] int NULL, 
	[YearKey] int NULL, 
	[LocationKey] int NULL, 
	[DateCreated] datetime2(6) NULL
);