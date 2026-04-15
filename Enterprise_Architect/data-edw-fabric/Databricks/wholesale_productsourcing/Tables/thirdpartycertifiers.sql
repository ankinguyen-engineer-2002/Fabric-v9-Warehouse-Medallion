CREATE TABLE [wholesale_productsourcing].[thirdpartycertifiers] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[tpaId] int NULL, 
	[tpaNumber] varchar(8000) NULL, 
	[tpaName] varchar(8000) NULL, 
	[tpaStartDate] datetime2(6) NULL, 
	[tpaEndDate] datetime2(6) NULL, 
	[tpaAddress1] varchar(8000) NULL, 
	[tpaAddress2] varchar(8000) NULL, 
	[tpaCity] varchar(8000) NULL, 
	[tpaState] varchar(8000) NULL, 
	[tpaCountryCode] varchar(8000) NULL, 
	[tpaContact] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[tpaActive] bit NULL, 
	[tpaContactPhone] varchar(8000) NULL
);

