CREATE TABLE [Retail_DW_Core].[FactSalesOrderCloses] (

	[SuperOrderID] varchar(50) NOT NULL, 
	[SourceOrderID] varchar(100) NULL, 
	[CountTypeID] varchar(10) NULL, 
	[CustomerID] varchar(30) NOT NULL, 
	[StoreID] bigint NOT NULL, 
	[SalesPersonID] varchar(30) NOT NULL, 
	[OrderDateKey] int NOT NULL, 
	[TransDateKey] int NOT NULL, 
	[SPSales] decimal(19,4) NULL, 
	[SPClose] decimal(19,4) NULL, 
	[SUClose] decimal(19,4) NULL, 
	[SUOpp] decimal(19,4) NULL, 
	[SOClose] decimal(19,4) NULL, 
	[SOOpp] decimal(19,4) NULL, 
	[CurrentRec] int NULL, 
	[DateChanged] datetime2(3) NULL
);