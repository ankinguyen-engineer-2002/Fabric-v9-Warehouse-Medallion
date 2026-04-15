CREATE TABLE [Wholesale_DemandPlanning_AFI].[ProductionTimeFence] (

	[Item] varchar(15) NULL, 
	[Location] char(7) NULL, 
	[Series] varchar(15) NULL, 
	[ProdResource] varchar(40) NULL, 
	[PlanProduction] int NULL, 
	[PlanningTimeFenceDays] int NULL, 
	[CurrentStatus] char(1) NULL, 
	[IsOverride] int NULL, 
	[OverrideDays] int NULL, 
	[MaterialOffset] int NULL, 
	[ProductionLeadTime] numeric(18,0) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL
);