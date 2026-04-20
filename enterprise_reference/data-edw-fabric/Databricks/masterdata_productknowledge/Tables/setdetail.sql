CREATE TABLE [masterdata_productknowledge].[setdetail] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[sdeCustomerNumber] varchar(8000) NULL, 
	[sdeSetNumber] varchar(8000) NULL, 
	[sdeItemNumber] varchar(8000) NULL, 
	[sdeQuantity] decimal(38,18) NULL, 
	[sdeKey] bit NULL, 
	[sdeOption] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

