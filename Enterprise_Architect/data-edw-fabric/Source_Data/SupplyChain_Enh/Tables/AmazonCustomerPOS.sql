CREATE TABLE [SupplyChain_Enh].[AmazonCustomerPOS] (

	[ASIN] varchar(50) NULL, 
	[ProductTitle] varchar(500) NULL, 
	[ItemSKU] varchar(100) NULL, 
	[OrderedRevenue] decimal(10,2) NULL, 
	[OrderedUnits] decimal(10,2) NULL, 
	[ShippedRevenue] decimal(10,2) NULL, 
	[ShippedCOGS] decimal(10,2) NULL, 
	[ShippedUnits] decimal(10,2) NULL, 
	[CustomerReturns] decimal(10,2) NULL, 
	[AverageShippedPrice] decimal(10,2) NULL, 
	[AverageShippedCost] decimal(10,2) NULL, 
	[JobRunDate] date NULL, 
	[SourceFoldersDate] date NULL, 
	[WeekEnding] date NULL
);