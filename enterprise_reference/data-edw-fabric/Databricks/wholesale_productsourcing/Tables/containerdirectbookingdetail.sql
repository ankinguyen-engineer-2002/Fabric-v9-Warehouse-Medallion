CREATE TABLE [wholesale_productsourcing].[containerdirectbookingdetail] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[cdbOrderNum] varchar(8000) NULL, 
	[cdbBookingNum] varchar(8000) NULL, 
	[cdbBookingStatusId] int NULL, 
	[cdbCargoReadyDate] datetime2(6) NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[cdbBookingSubmitDate] datetime2(6) NULL
);

