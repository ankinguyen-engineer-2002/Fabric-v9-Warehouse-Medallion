CREATE TABLE [Retail_Sales_Wrk].[OrderItemCommissionInfo] (

	[CommCalcCode] int NULL, 
	[CommFlg] bit NULL, 
	[CommPct] numeric(18,2) NOT NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[ItemCommCategory] varchar(10) NULL, 
	[ItemID] int NOT NULL, 
	[OrderCommCategory] varchar(10) NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[PosID] int NOT NULL, 
	[ProductID] varchar(50) NOT NULL, 
	[RecStatus] varchar(1) NULL, 
	[SalesPersonID] varchar(50) NOT NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[SplitPct] numeric(18,2) NOT NULL
);