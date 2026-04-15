CREATE TABLE [Retail_Sales_Enh].[SalesOrderCloses] (

	[SuperOrderID] varchar(50) NOT NULL, 
	[CountTypeID] varchar(10) NULL, 
	[CustomerID] varchar(30) NOT NULL, 
	[LocationID] bigint NOT NULL, 
	[SalesPersonID] varchar(30) NOT NULL, 
	[OrderDateKey] int NOT NULL, 
	[TransDateKey] int NOT NULL, 
	[SPSales] decimal(18,2) NULL, 
	[SPClose] decimal(18,2) NULL, 
	[SUClose] decimal(18,2) NULL, 
	[SUOpp] decimal(18,2) NULL, 
	[SOOpp] decimal(18,2) NULL, 
	[CurrentRec] int NULL, 
	[DateChanged] datetime2(3) NULL, 
	[OrderID] varchar(100) NULL, 
	[SOClose] decimal(18,2) NULL
);