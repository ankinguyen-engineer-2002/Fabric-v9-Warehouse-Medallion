CREATE TABLE [Retail_Dart].[SalesOrderCloses] (

	[SUOrderID] varchar(50) NOT NULL, 
	[CountTypeID] varchar(10) NULL, 
	[CustomerKey] bigint NOT NULL, 
	[LocationKey] bigint NOT NULL, 
	[SalesPersonKey] bigint NOT NULL, 
	[OrderDateKey] int NOT NULL, 
	[TransDateKey] int NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[SPSales] decimal(18,4) NULL, 
	[SPClose] decimal(18,2) NULL, 
	[SUClose] decimal(18,2) NULL, 
	[SOClose] decimal(18,2) NULL, 
	[SUOpp] decimal(18,2) NULL, 
	[SOOpp] decimal(18,2) NULL, 
	[CurrentRec] int NULL, 
	[DateChanged] datetime2(6) NULL, 
	[CustomerID] varchar(50) NOT NULL, 
	[LocationID] varchar(50) NOT NULL, 
	[SalespersonID] varchar(50) NOT NULL
);