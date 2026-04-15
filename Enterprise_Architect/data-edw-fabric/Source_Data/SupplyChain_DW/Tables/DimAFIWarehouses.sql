CREATE TABLE [SupplyChain_DW].[DimAFIWarehouses] (

	[AFIWarehousesKey] int NULL, 
	[WarehouseCode] char(3) NULL, 
	[IntransitWarehouse] char(3) NULL, 
	[ContainerDirectWarehouse] char(1) NULL, 
	[ControlledWarehouse] int NULL, 
	[WarehouseLocation] varchar(50) NULL, 
	[WarehouseOrderGroup] varchar(10) NULL, 
	[FinanceInventoryReportFlag] int NULL
);