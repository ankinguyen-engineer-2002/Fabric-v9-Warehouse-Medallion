CREATE TABLE [Retail_Sales_Enh].[SalesPersonHourlyStats] (

	[ID] bigint NOT NULL, 
	[Source] varchar(5) NOT NULL, 
	[StoreID] int NOT NULL, 
	[SalesPersonID] varchar(30) NOT NULL, 
	[TransDate] date NOT NULL, 
	[Hour] int NOT NULL, 
	[Ups] int NULL, 
	[DateCreated] datetime2(3) NULL, 
	[CreatedBy] varchar(10) NULL, 
	[DateChanged] datetime2(3) NULL, 
	[ChangedBy] varchar(10) NULL, 
	[Worked] bit NOT NULL, 
	[HourlyStatsSourceID] int NOT NULL, 
	[LiveIND] bit NOT NULL, 
	[StrikeOuts] int NULL, 
	[HotRotations] int NULL, 
	[Shots] int NULL
);