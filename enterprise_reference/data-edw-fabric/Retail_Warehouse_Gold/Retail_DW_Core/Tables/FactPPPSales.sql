CREATE TABLE [Retail_DW_Core].[FactPPPSales] (

	[StoreID] int NULL, 
	[TransDate] date NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[PPPGroupID] varchar(50) NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[Opp] decimal(19,4) NULL, 
	[Closes] decimal(19,4) NULL
);