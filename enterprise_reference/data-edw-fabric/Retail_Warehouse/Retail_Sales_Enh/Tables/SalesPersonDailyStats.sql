CREATE TABLE [Retail_Sales_Enh].[SalesPersonDailyStats] (

	[ID] bigint NOT NULL, 
	[Source] varchar(5) NOT NULL, 
	[StoreID] int NOT NULL, 
	[SalesPersonID] varchar(30) NOT NULL, 
	[TransDate] date NOT NULL, 
	[RecordedUps] int NULL, 
	[Prospects] int NULL, 
	[Treat] int NULL, 
	[Quotes] int NULL, 
	[Sold] int NULL, 
	[Worked] int NULL, 
	[BeBack] int NULL, 
	[DateCreated] datetime2(3) NULL, 
	[CreatedBy] varchar(10) NULL, 
	[DateChanged] datetime2(3) NULL, 
	[ChangedBy] varchar(10) NULL, 
	[StrikeOuts] int NULL, 
	[HotRotations] int NULL, 
	[Shots] int NULL
);