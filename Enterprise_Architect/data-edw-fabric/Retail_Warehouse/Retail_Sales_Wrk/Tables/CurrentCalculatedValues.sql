CREATE TABLE [Retail_Sales_Wrk].[CurrentCalculatedValues] (

	[OrderKey] bigint NULL, 
	[SalesDataTypeKey] int NULL, 
	[TransKey] varchar(50) NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[TransValue] decimal(18,2) NULL, 
	[OrderID] varchar(50) NULL
);