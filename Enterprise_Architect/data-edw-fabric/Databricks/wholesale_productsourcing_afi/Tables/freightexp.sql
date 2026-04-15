CREATE TABLE [wholesale_productsourcing_afi].[freightexp] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[fepordernum] varchar(8000) NULL, 
	[fepdate] datetime2(6) NULL, 
	[fepfee] decimal(38,18) NULL, 
	[fepcategory] varchar(8000) NULL, 
	[fepnote] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[fepCurrencyCode] varchar(8000) NULL, 
	[fepExchangeRate] decimal(38,18) NULL, 
	[fepID] int NULL
);

