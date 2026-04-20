CREATE TABLE [wholesale_productsourcing_afi].[freightitemtrans] (

	[fitOrderNum] varchar(8000) NULL, 
	[fitItemNum] varchar(8000) NULL, 
	[fitFreightFee] decimal(38,18) NULL, 
	[fitDatePaid] datetime2(6) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[fitPaymentID] int NULL, 
	[fitEnvDefaultFreightFee] decimal(38,18) NULL, 
	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL
);

