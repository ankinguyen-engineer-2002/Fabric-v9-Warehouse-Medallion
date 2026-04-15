CREATE TABLE [Wholesale_DemandPlanning_AFI].[PlannedRequirementsLogility] (

	[prqID] bigint NOT NULL, 
	[prqItem] varchar(15) NOT NULL, 
	[prqItemdescription] varchar(30) NOT NULL, 
	[prqWarehouse] char(3) NOT NULL, 
	[prqVendorNumber] char(8) NOT NULL, 
	[prqOrderNumber] varchar(25) NOT NULL, 
	[prqQuantity] decimal(13,3) NOT NULL, 
	[prqDuedate] decimal(8,0) NOT NULL, 
	[prqShipdate] decimal(8,0) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL
);