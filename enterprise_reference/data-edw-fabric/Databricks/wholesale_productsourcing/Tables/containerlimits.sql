CREATE TABLE [wholesale_productsourcing].[containerlimits] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[cnlWarehouse] varchar(8000) NULL, 
	[cnlViaCode] varchar(8000) NULL, 
	[cnlCubes] int NULL, 
	[cnlWeight] int NULL, 
	[cnlUnderCubed] int NULL, 
	[cnlOverCubed] int NULL
);

