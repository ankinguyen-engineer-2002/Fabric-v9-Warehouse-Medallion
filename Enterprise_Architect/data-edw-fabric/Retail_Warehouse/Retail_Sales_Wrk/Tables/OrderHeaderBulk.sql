CREATE TABLE [Retail_Sales_Wrk].[OrderHeaderBulk] (

	[OrderKey] bigint NOT NULL, 
	[OrderDate] datetime2(3) NULL, 
	[TransCodeID] int NULL, 
	[OrdCount] decimal(18,2) NULL, 
	[TransKey] varchar(50) NULL, 
	[SalesDataTypeKey] int NULL, 
	[MerchSubTot] decimal(18,2) NULL, 
	[TotalCharges] decimal(18,2) NULL, 
	[TotalTax] decimal(18,2) NULL, 
	[TotalInvoice] decimal(18,2) NULL, 
	[NetUnits] decimal(18,2) NULL, 
	[NetSales] decimal(18,2) NULL, 
	[OrderID] varchar(20) NULL
);