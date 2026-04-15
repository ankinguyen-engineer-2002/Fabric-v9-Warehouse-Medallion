CREATE TABLE [Retail_External].[LocationCalendar] (

	[LocationID] int NULL, 
	[TransDateKey] int NULL, 
	[OpenTime] varchar(20) NULL, 
	[CloseTime] varchar(20) NULL, 
	[IsOpen] int NULL, 
	[IsDelivery] int NULL, 
	[DateChanged] datetime2(6) NULL, 
	[ChangedBy] varchar(30) NULL, 
	[YearMonthKey] int NULL, 
	[YearKey] int NULL
);