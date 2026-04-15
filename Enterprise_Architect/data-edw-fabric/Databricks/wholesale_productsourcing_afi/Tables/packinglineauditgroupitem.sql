CREATE TABLE [wholesale_productsourcing_afi].[packinglineauditgroupitem] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[id] bigint NULL, 
	[packing_line_audit_id] bigint NULL, 
	[packing_line_audit_group_id] bigint NULL, 
	[item_no] varchar(8000) NULL, 
	[total_num] bigint NULL, 
	[fail_num] bigint NULL, 
	[fail_rate] decimal(38,18) NULL
);

