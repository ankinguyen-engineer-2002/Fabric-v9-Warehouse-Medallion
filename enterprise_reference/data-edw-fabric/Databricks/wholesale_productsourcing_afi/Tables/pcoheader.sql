CREATE TABLE [wholesale_productsourcing_afi].[pcoheader] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[cohPCONumber] int NULL, 
	[cohPCOProductType] varchar(8000) NULL, 
	[cohPCOFacility] varchar(8000) NULL, 
	[cohEffectiveDate] datetime2(6) NULL, 
	[cohPCOStatusCode] varchar(8000) NULL, 
	[cohCountermeasure] varchar(8000) NULL, 
	[cohNotes] varchar(8000) NULL, 
	[cohLastActionUserID] varchar(8000) NULL, 
	[cohPCOChangeAmount] decimal(38,18) NULL, 
	[cohPCORejectNote] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[cohPCOTransactionID] int NULL, 
	[cohPCOCreator] varchar(8000) NULL, 
	[cohNewItemPCO] varchar(8000) NULL, 
	[cohPCOCommodityID] int NULL
);

