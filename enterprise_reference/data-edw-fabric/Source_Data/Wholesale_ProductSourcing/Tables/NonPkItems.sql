CREATE TABLE [Wholesale_ProductSourcing].[NonPkItems] (

	[npkItemNumber] varchar(15) NOT NULL, 
	[npkFutureStatus] varchar(40) NOT NULL, 
	[npkHoldBuyCode] varchar(40) NOT NULL, 
	[usra] varchar(30) NULL, 
	[dtea] varchar(50) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] varchar(50) NULL, 
	[npkForecastPlannerID] varchar(40) NULL, 
	[npkDirectShipItemOnly] char(1) NULL
);