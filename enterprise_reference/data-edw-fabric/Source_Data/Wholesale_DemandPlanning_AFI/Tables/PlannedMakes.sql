CREATE TABLE [Wholesale_DemandPlanning_AFI].[PlannedMakes] (

	[ItemNumber] varchar(15) NULL, 
	[Warehouse] char(3) NULL, 
	[Quantity] numeric(18,0) NULL, 
	[StartDate] datetime2(6) NULL, 
	[DueDate] datetime2(6) NULL, 
	[DemandType] varchar(40) NULL, 
	[OrderSource] int NULL, 
	[TimeFence] datetime2(6) NULL
);