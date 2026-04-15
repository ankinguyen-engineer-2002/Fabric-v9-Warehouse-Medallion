CREATE TABLE [wholesale_productsourcing_afi].[spitemlocations] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[silItemNum] varchar(8000) NULL, 
	[silLocation] varchar(8000) NULL, 
	[silProdRsrc] varchar(8000) NULL, 
	[silPlanProduction] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[silTimeFenceOverride] bit NULL, 
	[silPlanningTimeFence] datetime2(6) NULL, 
	[silMakeBuyCode] varchar(8000) NULL, 
	[silControlFile] varchar(8000) NULL, 
	[silSourceLocation] varchar(8000) NULL
);

