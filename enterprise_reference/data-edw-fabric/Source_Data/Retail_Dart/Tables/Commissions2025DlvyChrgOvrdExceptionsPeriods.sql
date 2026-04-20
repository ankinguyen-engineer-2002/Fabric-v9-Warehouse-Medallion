CREATE TABLE [Retail_Dart].[Commissions2025DlvyChrgOvrdExceptionsPeriods] (

	[Operation] char(5) NULL, 
	[Id] int NOT NULL, 
	[StartDate] date NOT NULL, 
	[EndDate] date NOT NULL, 
	[MinSalesLimit] decimal(10,2) NOT NULL, 
	[UsePromoItem] int NULL, 
	[PerDayStoreLimit] int NULL
);