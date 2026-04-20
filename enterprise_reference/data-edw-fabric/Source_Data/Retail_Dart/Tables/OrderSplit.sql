CREATE TABLE [Retail_Dart].[OrderSplit] (

	[Operation] char(8) NULL, 
	[OrderSplitID] bigint NOT NULL, 
	[OrderKey] bigint NOT NULL, 
	[SalesPersonID] varchar(50) NOT NULL, 
	[SplitPercent] decimal(18,2) NOT NULL, 
	[CurrentRec] bit NOT NULL, 
	[DateCreated] datetime2(6) NULL, 
	[OrderID] varchar(20) NULL
);