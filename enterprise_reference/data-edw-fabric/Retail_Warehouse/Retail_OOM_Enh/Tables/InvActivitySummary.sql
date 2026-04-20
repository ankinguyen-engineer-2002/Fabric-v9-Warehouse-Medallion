CREATE TABLE [Retail_OOM_Enh].[InvActivitySummary] (

	[LocationID] varchar(50) NOT NULL, 
	[ActivityCodeID] varchar(10) NOT NULL, 
	[StaffID] varchar(50) NOT NULL, 
	[TransDate] datetime2(3) NOT NULL, 
	[ActivityQty] int NULL
);