CREATE TABLE [Retail_Sales_Enh].[ScoreboardActivity] (

	[Source] varchar(5) NULL, 
	[StoreID] int NULL, 
	[ScoreboardStoreID] int NULL, 
	[LocationName] varchar(255) NULL, 
	[SalesPersonID] varchar(20) NULL, 
	[SalesPersonName] varchar(50) NULL, 
	[StatusStartDate] date NULL, 
	[TotalStatusLength] int NULL, 
	[RecordCount] int NULL, 
	[RecordedUps] int NULL, 
	[RecordedClosed] int NULL, 
	[Strikes] int NULL, 
	[StrikeOuts] int NULL, 
	[Shots] int NULL, 
	[FinApps] int NULL, 
	[MaxConsecutiveStrikes] int NULL, 
	[MaxConsecutiveStrikeOuts] int NULL, 
	[LastConsecutiveStrikes] int NULL, 
	[LastConsecutiveStrikeOuts] int NULL, 
	[RedLineCrossedCount] int NULL
);