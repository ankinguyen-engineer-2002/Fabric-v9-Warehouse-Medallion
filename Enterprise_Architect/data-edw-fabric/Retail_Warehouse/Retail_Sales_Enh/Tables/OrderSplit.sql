CREATE TABLE [Retail_Sales_Enh].[OrderSplit] (

	[OrderSplitID] bigint NULL, 
	[OrderKey] bigint NULL, 
	[SalesPersonID] varchar(50) NOT NULL, 
	[SplitPercent] decimal(18,2) NOT NULL, 
	[CurrentRec] bit NOT NULL, 
	[DateCreated] datetime2(3) NULL, 
	[OrderID] varchar(20) NULL
);