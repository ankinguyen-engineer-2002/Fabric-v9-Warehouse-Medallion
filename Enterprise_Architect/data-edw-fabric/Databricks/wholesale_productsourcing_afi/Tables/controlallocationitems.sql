CREATE TABLE [wholesale_productsourcing_afi].[controlallocationitems] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[caiItemNumber] varchar(8000) NULL, 
	[caiControlAllocation] varchar(8000) NULL, 
	[caiDescription] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[caiControlledProduct] varchar(8000) NULL, 
	[caiCRD] datetime2(6) NULL, 
	[caiExceptionToATPSeries] varchar(8000) NULL, 
	[caiWarehouse] varchar(8000) NULL, 
	[caiLastUserChanged] varchar(8000) NULL
);

