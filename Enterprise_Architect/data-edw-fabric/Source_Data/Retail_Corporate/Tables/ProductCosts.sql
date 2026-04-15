CREATE TABLE [Retail_Corporate].[ProductCosts] (

	[Operation] varchar(15) NULL, 
	[Addon1Cost] numeric(19,4) NULL, 
	[Addon2Cost] numeric(19,4) NULL, 
	[Addon3Cost] numeric(19,4) NULL, 
	[Addon4Cost] numeric(19,4) NULL, 
	[AverageCost] numeric(19,4) NULL, 
	[CountryID] varchar(50) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[ExchangeRate] numeric(12,6) NULL, 
	[LandedFreight] numeric(19,4) NULL, 
	[LastBatchID] int NULL, 
	[MaterialCost] numeric(19,4) NULL, 
	[ProductID] varchar(50) NULL, 
	[RecStatus] char(1) NULL, 
	[ReplacementCost] numeric(19,4) NULL, 
	[SourceID] varchar(50) NULL
);