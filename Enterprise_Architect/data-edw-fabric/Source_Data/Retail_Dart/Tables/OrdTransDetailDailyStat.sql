CREATE TABLE [Retail_Dart].[OrdTransDetailDailyStat] (

	[TransDate] date NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[BookedStoreID] varchar(50) NULL, 
	[DCStoreID] varchar(50) NULL, 
	[ItemID] int NOT NULL, 
	[DeliveryStatus] varchar(10) NULL, 
	[DeliveryDate] date NULL, 
	[NumDlvyDateChg] int NULL, 
	[ScheduleSource] varchar(10) NULL, 
	[ScheduleBy] varchar(50) NULL, 
	[ScheduleChangeType] int NULL, 
	[SupplySource] char(5) NULL, 
	[SupplySourceDate] date NULL, 
	[SupplySourceID] varchar(50) NULL, 
	[SupplySourceLineID] int NULL, 
	[FirstSchedule] int NULL, 
	[ScheduleToday] int NULL, 
	[QtyOrdered] int NULL, 
	[QtyCommitted] int NULL, 
	[OrderAmt] decimal(19,5) NULL
);