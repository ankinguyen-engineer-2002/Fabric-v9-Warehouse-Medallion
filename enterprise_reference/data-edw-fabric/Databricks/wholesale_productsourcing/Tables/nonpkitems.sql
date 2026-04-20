CREATE TABLE [wholesale_productsourcing].[nonpkitems] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[npkItemNumber] varchar(8000) NULL, 
	[npkFutureStatus] varchar(8000) NULL, 
	[npkHoldBuyCode] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] varchar(8000) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] varchar(8000) NULL, 
	[npkForecastPlannerID] varchar(8000) NULL, 
	[npkDirectShipItemOnly] varchar(8000) NULL
);

