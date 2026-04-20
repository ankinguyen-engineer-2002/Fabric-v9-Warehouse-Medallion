CREATE TABLE [Retail_Corporate].[OrderItem_CommissionInfo] (

	[Operation] varchar(15) NULL, 
	[CommCalcCode] int NULL, 
	[CommFlg] bit NULL, 
	[CommPct] numeric(18,2) NULL, 
	[CompanyID] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[ItemCommCategory] varchar(10) NULL, 
	[ItemID] int NULL, 
	[OrderCommCategory] varchar(10) NULL, 
	[OrderID] varchar(50) NULL, 
	[PosID] int NULL, 
	[ProductID] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[SourceID] varchar(50) NULL, 
	[SplitPct] numeric(18,2) NULL
);