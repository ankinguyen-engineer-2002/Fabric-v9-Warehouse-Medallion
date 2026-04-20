CREATE TABLE [Retail_Sales_Wrk].[ProtectionPlanSalesTrans] (

	[PPSalesKey] bigint NOT NULL, 
	[SalesDataTypeKey] int NOT NULL, 
	[ProtectionPlanID] varchar(50) NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[ItemID] int NOT NULL, 
	[Base_OrderID] varchar(50) NULL, 
	[LocationID] varchar(50) NOT NULL, 
	[SalesPersonID] varchar(50) NOT NULL, 
	[TransDate] date NOT NULL, 
	[TransCodeID] int NOT NULL, 
	[Sales] decimal(18,2) NOT NULL, 
	[Cost] decimal(18,2) NOT NULL, 
	[Units] decimal(18,2) NOT NULL, 
	[Source] char(1) NOT NULL, 
	[CurrentRec] int NOT NULL, 
	[DateCreated] datetime2(3) NOT NULL, 
	[CustomerID] varchar(50) NULL
);