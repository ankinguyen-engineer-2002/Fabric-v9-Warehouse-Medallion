CREATE TABLE [wholesale_productsourcing].[carrier_source] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_keys] varchar(8000) NULL, 
	[ltd_filename] varchar(8000) NULL, 
	[ltd_DropProgram] varchar(8000) NULL, 
	[ltd_DropLocation] varchar(8000) NULL, 
	[ltd_row_number1] int NULL, 
	[ltd_count1] bigint NULL, 
	[ltd_row_number2] int NULL, 
	[ltd_count2] bigint NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_mergeInsert] bit NULL, 
	[carid] int NULL, 
	[carname] varchar(8000) NULL, 
	[carSCAC] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[carActive] bit NULL, 
	[carWebsite] varchar(8000) NULL, 
	[carParentCarrierID] int NULL, 
	[carCLSQualified] bit NULL
);

