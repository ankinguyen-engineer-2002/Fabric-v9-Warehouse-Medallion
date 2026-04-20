CREATE TABLE [Retail_DW_Core].[LEAS_FactLeaseWrittenSales] (

	[TransDateKey] int NULL, 
	[SalesPersonKey] int NULL, 
	[LocationKey] int NULL, 
	[IsLeasedVendor] int NULL, 
	[FinanceProviderID] varchar(8000) NULL, 
	[PaymentTypeID] varchar(8000) NULL, 
	[PaymentTypeName] varchar(8000) NULL, 
	[WrittenSales] decimal(18,4) NULL, 
	[FinWrittenSales] decimal(18,4) NULL
);