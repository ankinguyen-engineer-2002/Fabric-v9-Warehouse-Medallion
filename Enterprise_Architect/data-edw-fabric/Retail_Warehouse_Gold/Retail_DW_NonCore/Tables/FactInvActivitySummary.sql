CREATE TABLE [Retail_DW_NonCore].[FactInvActivitySummary] (

	[LocationKey] int NULL, 
	[LocationID] char(10) NOT NULL, 
	[ActivityCodeID] varchar(10) NOT NULL, 
	[StaffID] varchar(50) NOT NULL, 
	[TransDateKey] int NOT NULL, 
	[ActivityQty] int NULL
);