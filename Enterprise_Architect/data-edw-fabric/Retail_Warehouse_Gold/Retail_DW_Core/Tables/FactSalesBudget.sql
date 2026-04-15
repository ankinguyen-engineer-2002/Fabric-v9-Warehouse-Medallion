CREATE TABLE [Retail_DW_Core].[FactSalesBudget] (

	[StoreID] bigint NOT NULL, 
	[TransDate] date NULL, 
	[DateCreated] datetime2(6) NULL, 
	[CategoryID] varchar(10) NULL, 
	[GroupID] varchar(50) NULL, 
	[WrittenSales] decimal(18,4) NULL, 
	[WrittenGM] decimal(18,4) NULL, 
	[DeliveredSales] decimal(18,4) NULL, 
	[DeliveredGM] decimal(18,4) NULL, 
	[PrimaryCategory] int NULL
);