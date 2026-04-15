CREATE TABLE [Retail_DW_Core].[FactSalesOrderTrans] (

	[SalesOrderHistKey] bigint NULL, 
	[OrderKey] bigint NULL, 
	[OrderID] [varchar](30) NULL,
	[SalesDataTypeKey] int NOT NULL, 
	[TransDateKey] int NOT NULL, 
	[SalesPersonID] varchar(50) NOT NULL, 
	[TransValue] decimal(18,2) NULL, 
	[TransKey] varchar(50) NOT NULL, 
	[CurrentRec] bit NULL, 
	[DateCreated] datetime2(3) NULL
);