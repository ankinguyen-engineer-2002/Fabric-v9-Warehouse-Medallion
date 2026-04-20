CREATE TABLE [Wholesale_DemandPlanning_AFI].[ProductionResourcePlan] (

	[Item] varchar(40) NOT NULL, 
	[Location] varchar(40) NOT NULL, 
	[ProductionResource] varchar(40) NOT NULL, 
	[Qty] float NOT NULL, 
	[ProductionDate] datetime2(6) NOT NULL, 
	[DwellDate] datetime2(6) NOT NULL, 
	[CapacityUtilization] float NOT NULL, 
	[ProductionType] varchar(40) NOT NULL
);