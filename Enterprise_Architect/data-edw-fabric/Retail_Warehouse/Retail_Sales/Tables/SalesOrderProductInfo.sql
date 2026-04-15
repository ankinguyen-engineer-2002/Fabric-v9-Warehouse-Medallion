CREATE TABLE [Retail_Sales].[SalesOrderProductInfo] (

	[SourceSystem] varchar(30) NOT NULL, 
	[SourceOrderID] varchar(20) NOT NULL, 
	[InfoStatus] varchar(30) NOT NULL, 
	[SKU] varchar(20) NOT NULL, 
	[LineNumber] int NOT NULL, 
	[PieceID] int NOT NULL, 
	[ReasonCodeID] varchar(50) NULL, 
	[SerialNumber] varchar(50) NULL, 
	[TotalCost] decimal(19,4) NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[RecStatus] char(1) NULL
);