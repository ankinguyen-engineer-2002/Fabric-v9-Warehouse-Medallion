CREATE TABLE [masterdata_productknowledge].[wheremadecrossreference] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[wmcWhereMade] varchar(8000) NULL, 
	[wmcManufacturingSite] varchar(8000) NULL, 
	[wmcWarehouse] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

