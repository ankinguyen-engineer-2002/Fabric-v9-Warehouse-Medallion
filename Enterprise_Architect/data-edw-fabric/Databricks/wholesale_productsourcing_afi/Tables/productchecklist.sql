CREATE TABLE [wholesale_productsourcing_afi].[productchecklist] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[id] int NULL, 
	[office] varchar(8000) NULL, 
	[vendor_no] varchar(8000) NULL, 
	[item_id] int NULL, 
	[vendor_name] varchar(8000) NULL, 
	[time_market] varchar(8000) NULL, 
	[show_market_id] int NULL, 
	[qa_team] varchar(8000) NULL, 
	[operator] varchar(8000) NULL, 
	[update_time] datetime2(6) NULL, 
	[updater] varchar(8000) NULL, 
	[qc_name] varchar(8000) NULL, 
	[max_version] int NULL, 
	[vendor_item_status] varchar(8000) NULL, 
	[ignore_sku_approve] smallint NULL, 
	[created_on] datetime2(6) NULL, 
	[created_by] int NULL, 
	[last_modified_on] datetime2(6) NULL, 
	[last_modified_by] int NULL
);

