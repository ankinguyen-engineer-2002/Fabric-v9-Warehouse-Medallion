CREATE TABLE [SupplyChain_Enh].[AmazonCustomerForecast] (

	[ItemSKU] varchar(100) NULL, 
	[ASIN] varchar(50) NULL, 
	[Quantity] int NULL, 
	[Snapshotdate] date NULL, 
	[JobRunDate] date NULL, 
	[SourceFoldersDate] date NULL, 
	[WeekEnding] date NULL
);