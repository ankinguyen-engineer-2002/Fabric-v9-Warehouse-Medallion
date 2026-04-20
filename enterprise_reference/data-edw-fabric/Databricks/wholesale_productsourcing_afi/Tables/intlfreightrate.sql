CREATE TABLE [wholesale_productsourcing_afi].[intlfreightrate] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[ifrfobcode] varchar(8000) NULL, 
	[ifrdestinationid] int NULL, 
	[ifrcarrierid] int NULL, 
	[ifrviacode] varchar(8000) NULL, 
	[ifrfreight] int NULL, 
	[ifrstartdate] datetime2(6) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[ifrEndDate] datetime2(6) NULL
);

