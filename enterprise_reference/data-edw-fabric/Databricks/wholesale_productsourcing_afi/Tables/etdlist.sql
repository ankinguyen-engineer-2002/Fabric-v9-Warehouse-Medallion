CREATE TABLE [wholesale_productsourcing_afi].[etdlist] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[etdordernum] varchar(8000) NULL, 
	[etdetd] datetime2(6) NULL, 
	[etdeta] datetime2(6) NULL, 
	[etdduedate] datetime2(6) NULL, 
	[etdchangeby] varchar(8000) NULL, 
	[etdreason] varchar(8000) NULL, 
	[etdcurrentestimate] bit NULL, 
	[etdoriginalestimate] bit NULL, 
	[etdchangedate] varchar(8000) NULL, 
	[etdashleyestimate] bit NULL, 
	[etdusername] varchar(8000) NULL, 
	[etdneedby] bit NULL, 
	[etdExpectedDelivery] datetime2(6) NULL
);

