CREATE TABLE [wholesale_productsourcing].[vendordirecttransactionlog] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[dslSource] varchar(8000) NULL, 
	[dslID] decimal(38,18) NULL, 
	[dslCustomerOrderNumber] varchar(8000) NULL, 
	[dslCOPONumber] varchar(8000) NULL, 
	[dslVendorPONumber] varchar(8000) NULL, 
	[dslSalesOrderNumber] varchar(8000) NULL, 
	[dslCustomerNumber] varchar(8000) NULL, 
	[dslSystemTransactionID] varchar(8000) NULL, 
	[dslSystem] varchar(8000) NULL, 
	[dslVendorNumber] varchar(8000) NULL, 
	[dslShipToNumber] varchar(8000) NULL, 
	[dslVendorInvoiceNumber] varchar(8000) NULL, 
	[dslCOInvoiceNumber] decimal(38,18) NULL, 
	[dslErrorNumber] varchar(8000) NULL, 
	[dslEventCode] varchar(8000) NULL, 
	[dslNotes] varchar(8000) NULL, 
	[dslProcessCode] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

