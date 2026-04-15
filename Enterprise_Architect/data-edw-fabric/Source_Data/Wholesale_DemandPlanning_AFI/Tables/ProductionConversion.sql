CREATE TABLE [Wholesale_DemandPlanning_AFI].[ProductionConversion] (

	[ItemId] varchar(40) NOT NULL, 
	[LocationId] varchar(40) NOT NULL, 
	[ProdResourceId] varchar(40) NOT NULL, 
	[BeginEffectiveDate] datetime2(6) NOT NULL, 
	[EndEffectiveDate] datetime2(6) NOT NULL, 
	[BeginEffectiveProduction] numeric(5,0) NOT NULL, 
	[EndEffectiveProduction] numeric(5,0) NOT NULL, 
	[MaterialCostValue] float NOT NULL, 
	[UnitProdHrsQty] float NOT NULL, 
	[UnitProdDurDays] numeric(3,0) NOT NULL, 
	[UnitProdHrsPerdayQty] float NOT NULL, 
	[RatePerHour] float NOT NULL, 
	[CreatedDate] datetime2(6) NOT NULL, 
	[ModifiedDate] datetime2(6) NOT NULL, 
	[ModifiedBy] varchar(40) NOT NULL, 
	[ReviewStatusIndicator] char(1) NOT NULL, 
	[RemNumber] int NULL, 
	[MinProdPerdayQty] float NOT NULL, 
	[ShelfLifeDays] numeric(5,0) NOT NULL, 
	[SnapshotDate] datetime2(6) NULL
);