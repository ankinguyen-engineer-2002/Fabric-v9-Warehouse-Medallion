CREATE TABLE [Retail_DW_Core].[FactTrafficandCloseBudget] (

	[StoreID] bigint NOT NULL, 
	[TransDate] date NULL, 
	[TUGoal] decimal(18,4) NULL, 
	[CloseGoal] decimal(38,9) NULL, 
	[RUGoal] decimal(38,9) NULL
);