CREATE TABLE [Wholesale_ProductSourcing_AFI].[ControlAllocationItems] (

	[caiItemNumber] varchar(15) NULL, 
	[caiControlAllocation] char(1) NULL, 
	[caiDescription] varchar(30) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[caiControlledProduct] char(1) NULL, 
	[caiCRD] date NULL, 
	[caiExceptionToATPSeries] char(1) NULL, 
	[caiWarehouse] char(3) NULL, 
	[caiLastUserChanged] varchar(30) NULL
);