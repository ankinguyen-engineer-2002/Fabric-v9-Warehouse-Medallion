CREATE TABLE [Retail_Miniapps].[DTRContractorData] (

	[Operation] varchar(50) NULL, 
	[ID] int NOT NULL, 
	[LocationID] varchar(50) NULL, 
	[EntryTypeID] int NULL, 
	[TransDate] date NULL, 
	[RegularCost] decimal(6,2) NULL, 
	[OvertimeCost] decimal(6,2) NULL, 
	[RegularHours] decimal(13,2) NULL, 
	[OvertimeHours] decimal(13,2) NULL, 
	[Pieces] decimal(13,2) NULL, 
	[ModifiedDate] datetime2(6) NULL, 
	[ModifiedBy] varchar(50) NULL
);