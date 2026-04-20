CREATE TABLE [Retail_Sales_Wrk].[AllCurrentCloseValues] (

	[SuperOrderID] varchar(100) NULL, 
	[CustomerID] varchar(100) NULL, 
	[StoreID] varchar(100) NULL, 
	[OrderDateKey] varchar(8) NULL, 
	[SalesPersonID] varchar(100) NULL, 
	[Sales] decimal(18,2) NULL, 
	[SPClose] decimal(18,2) NULL, 
	[SUClose] decimal(18,2) NULL, 
	[TransDateKey] varchar(8) NULL, 
	[OrderID] varchar(100) NULL, 
	[SOClose] decimal(18,2) NULL
);