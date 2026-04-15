CREATE TABLE [Retail_Sales_Wrk].[OrderHeader] (

	[OrderKey] bigint NULL, 
	[OrderDate] datetime2(3) NULL, 
	[TransCodeID] int NULL, 
	[TotalCharges] decimal(18,3) NULL, 
	[TotalTaxes] decimal(18,3) NULL, 
	[TotalSales] decimal(18,3) NULL, 
	[OrderID] varchar(20) NULL, 
	[TransDateKey] bigint NULL
);