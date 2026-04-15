CREATE TABLE [wholesale_productsourcing_afi].[pomisccharges] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[pmiChargeID] int NULL, 
	[pmiOrderNumber] varchar(8000) NULL, 
	[pmiAmount] decimal(38,18) NULL, 
	[pmiCreated] datetime2(6) NULL, 
	[pmiCreatedBy] varchar(8000) NULL, 
	[pmiNote] varchar(8000) NULL, 
	[pmiUnit] varchar(8000) NULL, 
	[pmiNature] varchar(8000) NULL, 
	[pmiCategoryID] int NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[pmiDatePaid] datetime2(6) NULL, 
	[pmiBuyerEntity] varchar(8000) NULL
);

