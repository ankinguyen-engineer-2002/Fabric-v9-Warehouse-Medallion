CREATE TABLE [wholesale_productsourcing_afi].[popaymentcategories] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[ppcCategoryCode] int NULL, 
	[ppcDescription] varchar(8000) NULL, 
	[ppcActive] bit NULL, 
	[ppcAdjustmentCategory] bit NULL, 
	[ppcChargeCategory] bit NULL, 
	[ppcPartialPayCategory] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[ppcVendorCategory] bit NULL
);

