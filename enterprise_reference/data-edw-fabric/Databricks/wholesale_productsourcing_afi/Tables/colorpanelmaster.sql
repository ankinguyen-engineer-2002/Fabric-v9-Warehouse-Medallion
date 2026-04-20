CREATE TABLE [wholesale_productsourcing_afi].[colorpanelmaster] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[id] bigint NULL, 
	[colorpanel_id] bigint NULL, 
	[version] varchar(8000) NULL, 
	[request_sending_date] datetime2(6) NULL, 
	[receiving_date] datetime2(6) NULL, 
	[to_vendor_date] datetime2(6) NULL, 
	[notice_send_date] datetime2(6) NULL, 
	[approved_date] datetime2(6) NULL, 
	[approved_by] varchar(8000) NULL, 
	[status] smallint NULL, 
	[disposed_year] varchar(8000) NULL, 
	[image_front] varchar(8000) NULL, 
	[image_back] varchar(8000) NULL, 
	[spec_characteristic_img] varchar(8000) NULL, 
	[total_signed_qty] bigint NULL, 
	[office_remain_qty] bigint NULL, 
	[created_time] datetime2(6) NULL, 
	[updated_time] datetime2(6) NULL, 
	[panel_location] varchar(8000) NULL
);

