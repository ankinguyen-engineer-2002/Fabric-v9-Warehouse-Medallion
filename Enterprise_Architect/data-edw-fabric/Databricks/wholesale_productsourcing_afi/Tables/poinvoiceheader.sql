CREATE TABLE [wholesale_productsourcing_afi].[poinvoiceheader] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[ivhOrderNumber] varchar(8000) NULL, 
	[ivhRevisionNumber] int NULL, 
	[ivhInvoiceNumber] varchar(8000) NULL, 
	[ivhInvoiceStatus] varchar(8000) NULL, 
	[ivhCertifyingStatement] varchar(8000) NULL, 
	[ivhCertifiedByVendor] bit NULL, 
	[ivhSolidWoodStatement] varchar(8000) NULL, 
	[ivhSolidWoodPackingMaterial] bit NULL, 
	[ivhTotalPaymentToVendor] decimal(38,18) NULL, 
	[ivhSellerContactFullName] varchar(8000) NULL, 
	[ivhSellerContactPhone] varchar(8000) NULL, 
	[ivhSellerContactEmail] varchar(8000) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

