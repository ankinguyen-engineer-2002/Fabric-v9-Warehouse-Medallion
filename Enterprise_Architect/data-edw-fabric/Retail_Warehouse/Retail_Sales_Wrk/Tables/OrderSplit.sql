CREATE TABLE [Retail_Sales_Wrk].[OrderSplit] (

	[OrderID] varchar(50) NOT NULL, 
	[SalesPersonID] varchar(50) NOT NULL,
	[TransDateKey] int NOT NULL, 
	[DataSource] varchar(3) NOT NULL, 
	[TransCodeID] int NOT NULL, 
	[SalesType] char(1) NOT NULL, 
	[NetSales] decimal(18,2) NULL, 
	[NetUnits] decimal(18,2) NULL
);