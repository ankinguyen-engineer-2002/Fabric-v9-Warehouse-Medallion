CREATE TABLE [Retail_Dart].[SFMCCustomerAttribution] (

	[ID] int NOT NULL, 
	[TransDate] datetime2(6) NOT NULL, 
	[CustomerID] varchar(50) NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[StoreID] varchar(50) NOT NULL, 
	[AttributedWrittenSales] decimal(19,5) NULL, 
	[SFMCStoreBrandID] varchar(50) NOT NULL, 
	[Epsilon] bit NULL
);