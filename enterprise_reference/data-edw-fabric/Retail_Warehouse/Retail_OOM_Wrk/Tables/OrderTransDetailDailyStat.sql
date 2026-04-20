CREATE TABLE [Retail_OOM_Wrk].[OrderTransDetailDailyStat] (

	[TransDate] date NOT NULL, 
	[OrderID] varchar(50) NOT NULL, 
	[ItemID] int NOT NULL, 
	[DeliveryStatus] varchar(10) NULL, 
	[DeliveryDate] date NULL, 
	[NumDeliveryDateChanged] int NULL, 
	[ScheduleSource] varchar(10) NULL, 
	[ScheduleBy] varchar(50) NULL, 
	[SupplySource] varchar(5) NULL, 
	[SupplySourceDate] date NULL, 
	[SupplySourceID] varchar(50) NULL, 
	[SupplySourceLineID] int NULL, 
	[FirstSchedule] int NULL, 
	[ScheduleToday] int NULL, 
	[ScheduleChangeType] int NULL, 
	[QuantityOrdered] int NULL, 
	[QuantityCommitted] int NULL, 
	[OrderAmount] decimal(19,4) NULL, 
	[BookedStoreID] varchar(50) NULL, 
	[DCStoreID] varchar(50) NULL
);