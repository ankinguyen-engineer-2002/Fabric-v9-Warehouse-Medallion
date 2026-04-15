CREATE TABLE [Retail_Sales_Enh].[SalesAssociateCommission] (

	[SourceSystem] varchar(30) NOT NULL, 
	[SalesPersonID] varchar(20) NOT NULL, 
	[SourceOrderID] varchar(30) NOT NULL, 
	[SKU] varchar(20) NOT NULL, 
	[LineNumber] int NULL, 
	[PosID] int NOT NULL, 
	[ItemCommCategory] varchar(10) NULL, 
	[CommissionStatus] varchar(30) NOT NULL, 
	[PercentCommission] decimal(19,4) NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[RecStatus] char(1) NULL
);