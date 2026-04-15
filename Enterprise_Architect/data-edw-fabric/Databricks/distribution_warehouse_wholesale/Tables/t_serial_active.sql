CREATE TABLE [distribution_warehouse_wholesale].[t_serial_active] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[wh_id] varchar(8000) NULL, 
	[serial_number] varchar(8000) NULL, 
	[item_number] varchar(8000) NULL, 
	[po_number] varchar(8000) NULL, 
	[serial_no_status] varchar(8000) NULL, 
	[status_change] datetime2(6) NULL, 
	[trip_number] varchar(8000) NULL, 
	[location_id] varchar(8000) NULL, 
	[hu_id] varchar(8000) NULL, 
	[received_date] datetime2(6) NULL, 
	[ship_date] datetime2(6) NULL, 
	[sscc_code] varchar(8000) NULL, 
	[master_status] varchar(8000) NULL, 
	[master_po] varchar(8000) NULL, 
	[born_on_date] datetime2(6) NULL, 
	[wh_id2] varchar(8000) NULL
);

