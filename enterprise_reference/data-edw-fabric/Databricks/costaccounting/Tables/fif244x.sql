CREATE TABLE [costaccounting].[fif244x] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[FDCINVOICENUMBER] decimal(9,0) NULL, 
	[FDCORDERNUMBER] varchar(8000) NULL, 
	[FDCINVOICEDATE] datetime2(6) NULL, 
	[FDCITEMSEQUENCE] decimal(7,0) NULL, 
	[FDCDISCOUNTTYPE] varchar(8000) NULL, 
	[FDCDISCOUNTADJUSTMENTCODE] varchar(8000) NULL, 
	[FDCITEMNUMBER] varchar(8000) NULL, 
	[FDCAMOUNT] decimal(16,6) NULL, 
	[FDCRATIOAMOUNT] decimal(16,6) NULL, 
	[FDCDISCOUNTPERCENT] decimal(5,4) NULL, 
	[FDCEXCEPTIONID] decimal(7,0) NULL, 
	[FDCDISCOUNTCODE] varchar(8000) NULL, 
	[FDCDISCOUNTSALESCLASS] varchar(8000) NULL, 
	[FDCADJUSTMENTAMOUNT] decimal(12,2) NULL
);