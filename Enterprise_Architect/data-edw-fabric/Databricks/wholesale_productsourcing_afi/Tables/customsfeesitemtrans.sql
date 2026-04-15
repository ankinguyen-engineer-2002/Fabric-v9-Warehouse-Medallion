CREATE TABLE [wholesale_productsourcing_afi].[customsfeesitemtrans] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[citID] int NULL, 
	[citOrderNum] varchar(8000) NULL, 
	[citItemNum] varchar(8000) NULL, 
	[citDatePaid] datetime2(6) NULL, 
	[citMPF] decimal(38,18) NULL, 
	[citHMF] decimal(38,18) NULL, 
	[citADD] decimal(38,18) NULL, 
	[citDuty] decimal(38,18) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[citCVD] decimal(38,18) NULL, 
	[citCottonFee] decimal(38,18) NULL, 
	[citComboFees] decimal(38,18) NULL
);

