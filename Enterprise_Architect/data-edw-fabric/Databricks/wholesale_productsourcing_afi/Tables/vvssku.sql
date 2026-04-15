CREATE TABLE [wholesale_productsourcing_afi].[vvssku] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[id] int NULL, 
	[pro_id] int NULL, 
	[item_id] int NULL, 
	[item_no] varchar(8000) NULL, 
	[vendor_no] varchar(8000) NULL, 
	[vendor_status] smallint NULL, 
	[scp_status] smallint NULL, 
	[qa_status] smallint NULL, 
	[created_by] varchar(8000) NULL, 
	[created_on] datetime2(6) NULL, 
	[updater] varchar(8000) NULL, 
	[update_time] datetime2(6) NULL, 
	[type] varchar(8000) NULL, 
	[upload_to_smarteam] smallint NULL, 
	[deleted] smallint NULL, 
	[ppr_sign_off_date] varchar(8000) NULL
);

