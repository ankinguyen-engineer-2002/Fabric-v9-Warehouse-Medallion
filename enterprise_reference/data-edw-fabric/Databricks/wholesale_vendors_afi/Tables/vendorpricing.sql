CREATE TABLE [wholesale_vendors_afi].[vendorpricing] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[vdpvendornum] varchar(8000) NULL, 
	[vdpitemnum] varchar(8000) NULL, 
	[vdpprice] float NULL, 
	[vdpgrade] bit NULL, 
	[a] datetime2(6) NULL, 
	[vdpdesignfeepercent] int NULL, 
	[vdpsplit] float NULL, 
	[vdpforcedactive] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[vdpContainerDirectEligible] int NULL, 
	[vdpFreight] float NULL, 
	[vdpCurrencyCode] varchar(8000) NULL, 
	[vdpVATamount] decimal(38,18) NULL, 
	[vdpExchangeRate] decimal(38,18) NULL, 
	[vdpWarehousePricingOnly] varchar(8000) NULL, 
	[vdpItemType] varchar(8000) NULL, 
	[vdpProcessType] varchar(8000) NULL
);

