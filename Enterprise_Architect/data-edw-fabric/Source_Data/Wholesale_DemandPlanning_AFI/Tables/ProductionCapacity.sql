CREATE TABLE [Wholesale_DemandPlanning_AFI].[ProductionCapacity] (

	[ResourceID] varchar(40) NULL, 
	[LocationID] varchar(40) NULL, 
	[SolverDate] datetime2(6) NULL, 
	[FirmHours] float NULL, 
	[PlannedHours] float NULL, 
	[UnusedHours] float NULL, 
	[TotalAvailHours] float NULL
);