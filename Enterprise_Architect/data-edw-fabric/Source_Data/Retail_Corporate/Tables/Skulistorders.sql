CREATE TABLE [Retail_Corporate].[Skulistorders] (

	[Operation] varchar(15) NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[OrderType] varchar(60) NULL, 
	[StoreID] varchar(50) NOT NULL, 
	[StoreName] varchar(50) NULL, 
	[DC] varchar(50) NULL, 
	[orderDlvyStoreNM] varchar(50) NULL, 
	[OrderDate] date NULL, 
	[GroupID] varchar(50) NOT NULL, 
	[CategoryID] varchar(50) NOT NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[ProductDesc] varchar(100) NULL, 
	[CaseSellingPrice] numeric(19,4) NULL
);