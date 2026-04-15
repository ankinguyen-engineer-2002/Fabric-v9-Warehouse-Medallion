CREATE TABLE [Retail_DW_NonCore].[GLTransactions] (

	[Id] varchar(100) NULL, 
	[ItemId] varchar(100) NULL, 
	[CustomerKey] varchar(100) NULL, 
	[CustomerType] varchar(100) NULL, 
	[ReferenceNumber] varchar(100) NULL, 
	[PostDate] datetime2(3) NULL, 
	[PostTime] datetime2(3) NULL, 
	[Operator] varchar(50) NULL, 
	[HeaderComment] varchar(500) NULL, 
	[AccountNumber] varchar(100) NULL, 
	[TransDate] datetime2(3) NULL, 
	[Debit] decimal(18,3) NULL, 
	[Credit] decimal(18,3) NULL, 
	[Remark] varchar(4000) NULL, 
	[Description] varchar(500) NULL, 
	[YearId] int NULL, 
	[IsPeriod13] bit NULL, 
	[InvoiceId] varchar(50) NULL
);