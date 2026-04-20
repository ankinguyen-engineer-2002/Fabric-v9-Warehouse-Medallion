CREATE TABLE [MasterData_Retail_Ent].[StoreLocationCalendar] (

	[StoreID] int NULL, 
	[TransDateKey] bigint NULL, 
	[OpenTime] varchar(20) NULL, 
	[CloseTime] varchar(20) NULL, 
	[IsOpen] int NULL, 
	[IsDelivery] int NULL, 
	[DateChanged] datetime2(3) NULL, 
	[ChangedBy] varchar(50) NULL, 
	[YearMonthKey] bigint NULL, 
	[YearKey] bigint NULL
);