CREATE TABLE [Retail_DW_Core].[FactPayments] (

	[StoreBrandID] varchar(50) NULL, 
	[OrderID] varchar(50) NULL, 
	[CustomerID] varchar(50) NULL, 
	[StoreID] int NULL, 
	[OrderDate] datetime2(3) NULL, 
	[TransDate] date NULL, 
	[SalespersonID] varchar(50) NULL, 
	[SalesPersonName] varchar(255) NULL, 
	[SalesDataTypeKey] int NULL, 
	[Sales] decimal(18,2) NULL, 
	[Charges] decimal(18,2) NULL, 
	[Taxes] decimal(18,2) NULL, 
	[Payments] int NULL, 
	[FinanceFees] decimal(18,2) NULL, 
	[PaymentTypeGroupID] varchar(2) NULL, 
	[IsFinanced] int NULL, 
	[FinanceUseEe] decimal(18,2) NULL, 
	[Balance] decimal(18,2) NULL, 
	[PaymentTypeID] varchar(50) NULL, 
	[OrderIsFinanced] int NULL, 
	[DateCreated] datetime2(3) NULL
);