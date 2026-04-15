CREATE TABLE [Retail_Dart].[Unified2020RatesByBrackets] (

	[Operation] char(5) NULL, 
	[RateByBracketID] int NOT NULL, 
	[RateTypeID] int NOT NULL, 
	[StartPayPeriodID] int NOT NULL, 
	[LowLimit] float NOT NULL, 
	[HighLimit] float NOT NULL, 
	[RateValue] float NULL
);