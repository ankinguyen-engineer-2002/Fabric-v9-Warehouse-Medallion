CREATE TABLE [Retail_Sales_Wrk].[SOHistOrderSplit] (

	[OrderSplitID] bigint NULL, 
	[OrderKey] bigint NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[SplitPercent] decimal(18,2) NULL, 
	[CurrentRec] bit NULL, 
	[OrderID] varchar(20) NULL
);