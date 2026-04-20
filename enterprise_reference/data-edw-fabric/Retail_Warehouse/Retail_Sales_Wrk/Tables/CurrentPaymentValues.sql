CREATE TABLE [Retail_Sales_Wrk].[CurrentPaymentValues] (

	[OrderKey] bigint NULL, 
	[SalesDataTypeKey] int NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[TransKey] varchar(50) NULL, 
	[TransValue] decimal(18,2) NULL, 
	[OrderID] varchar(50) NULL
);