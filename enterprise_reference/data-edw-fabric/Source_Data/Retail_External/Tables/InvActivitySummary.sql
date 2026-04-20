CREATE TABLE [Retail_External].[InvActivitySummary] (

	[Operation] varchar(15) NULL, 
	[LocationID] varchar(50) NOT NULL, 
	[ActivityCodeID] varchar(10) NOT NULL, 
	[StaffID] varchar(50) NOT NULL, 
	[TransDate] datetime2(3) NOT NULL, 
	[ActivityQty] int NULL
);