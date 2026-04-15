CREATE TABLE [Retail_Dart].[SFMCCustomerAttributionOpens] (

	[ID] int NOT NULL, 
	[TransDate] datetime2(6) NOT NULL, 
	[CustomerID] varchar(50) NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[StoreID] varchar(50) NOT NULL, 
	[AttributedWrittenSalesOpens] decimal(19,4) NULL, 
	[SFMCStoreBrandID] varchar(50) NULL, 
	[Epsilon] bit NULL
);