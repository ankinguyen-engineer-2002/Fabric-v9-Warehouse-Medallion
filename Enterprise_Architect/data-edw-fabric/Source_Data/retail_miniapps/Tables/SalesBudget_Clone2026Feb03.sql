CREATE TABLE [Retail_Miniapps].[SalesBudget_Clone2026Feb03] (

	[LocationID] varchar(100) NULL, 
	[TransDate] datetime2(6) NULL, 
	[CategoryID] varchar(100) NULL, 
	[StoreBrandID] varchar(100) NULL, 
	[GroupID] varchar(100) NULL, 
	[DefaultPPPGroupID] varchar(100) NULL, 
	[WrittenSales] decimal(18,4) NULL, 
	[WrittenGM] decimal(18,4) NULL, 
	[DeliveredSales] decimal(18,4) NULL, 
	[DeliveredGM] decimal(18,4) NULL, 
	[PrimaryCategory] int NULL, 
	[SalesType] varchar(100) NULL, 
	[Sales] decimal(18,4) NULL, 
	[GM] decimal(18,4) NULL, 
	[DateCreated] datetime2(6) NULL
);