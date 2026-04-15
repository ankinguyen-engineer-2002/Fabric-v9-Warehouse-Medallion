CREATE TABLE [Retail_Dart].[SalesOrderHist] (

	[Operation] char(8) NULL, 
	[SalesOrderHistKey] bigint NOT NULL, 
	[OrderKey] bigint NULL, 
	[SalesDataTypeKey] int NOT NULL, 
	[TransDateKey] int NOT NULL, 
	[SalesPersonID] varchar(50) NOT NULL, 
	[TransValue] decimal(18,2) NULL, 
	[TransKey] varchar(50) NOT NULL, 
	[CurrentRec] bit NULL, 
	[DateCreated] datetime2(6) NULL, 
	[OrderID] varchar(20) NULL
);