CREATE TABLE [wholesale_productsourcing_afi].[oceanfreightcontract] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[OfcContractType] varchar(8000) NULL, 
	[OfcContractNum] varchar(8000) NULL, 
	[OfcMinRequirement] decimal(38,18) NULL, 
	[OfcContractStart] datetime2(6) NULL, 
	[OfcContractEnd] datetime2(6) NULL, 
	[Ofc20ftContract] decimal(38,18) NULL, 
	[Ofc40ftContract] decimal(38,18) NULL, 
	[Ofc40fthiContract] decimal(38,18) NULL, 
	[Ofc45ftContract] decimal(38,18) NULL, 
	[OfcDateCreated] datetime2(6) NULL, 
	[OfcContractDesc] varchar(8000) NULL, 
	[OfcUsevia] int NULL, 
	[OfcMetertOn] decimal(38,18) NULL, 
	[Timestamp_Column] varchar(8000) NULL, 
	[Usra] varchar(8000) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(8000) NULL, 
	[Dtec] datetime2(6) NULL
);

