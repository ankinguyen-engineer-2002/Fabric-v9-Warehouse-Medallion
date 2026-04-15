CREATE TABLE [Retail_Sales_Wrk].[AllChangedOrders] (

	[SuperOrderID] varchar(100) NULL, 
	[CountTypeID] varchar(10) NULL, 
	[CustomerID] varchar(100) NULL, 
	[LocationID] varchar(100) NULL, 
	[SalesPersonID] varchar(100) NULL, 
	[OrderDateKey] varchar(8) NULL, 
	[TransDateKey] int NOT NULL, 
	[Sales] decimal(20,2) NULL, 
	[SPClose] decimal(20,2) NULL, 
	[SUClose] decimal(20,2) NULL, 
	[SUOpp] int NOT NULL, 
	[SOOpp] int NOT NULL, 
	[CurrentRec] int NOT NULL, 
	[DateChanged] datetime2(3) NULL, 
	[OrderID] varchar(100) NULL, 
	[SOClose] decimal(20,2) NULL
);