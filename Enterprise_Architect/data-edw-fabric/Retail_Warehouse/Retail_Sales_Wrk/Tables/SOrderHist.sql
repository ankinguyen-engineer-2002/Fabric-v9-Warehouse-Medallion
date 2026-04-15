CREATE TABLE [Retail_Sales_Wrk].[SOrderHist] (

	[SalesOrderHistKey] bigint NULL, 
	[OrderKey] bigint NULL, 
	[SalesDataTypeKey] int NULL, 
	[TransDateKey] int NULL, 
	[SalesPersonID] varchar(50) NULL, 
	[TransValue] decimal(18,2) NULL, 
	[TransKey] varchar(50) NULL, 
	[CurrentRec] bit NULL, 
	[DateCreated] datetime2(3) NULL, 
	[OrderID] varchar(20) NULL
);