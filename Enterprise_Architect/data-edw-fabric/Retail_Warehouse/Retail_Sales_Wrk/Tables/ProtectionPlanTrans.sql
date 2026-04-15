CREATE TABLE [Retail_Sales_Wrk].[ProtectionPlanTrans] (

	[LocationID] varchar(50) NOT NULL, 
	[ProtectionPlanID] varchar(50) NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[ItemID] int NOT NULL, 
	[TransCodeID] int NOT NULL, 
	[SalesPersonID] varchar(50) NOT NULL, 
	[TransDate] date NOT NULL, 
	[Sales] decimal(18,2) NOT NULL, 
	[Cost] decimal(18,2) NULL, 
	[Units] decimal(18,2) NOT NULL, 
	[CustomerID] varchar(50) NULL
);