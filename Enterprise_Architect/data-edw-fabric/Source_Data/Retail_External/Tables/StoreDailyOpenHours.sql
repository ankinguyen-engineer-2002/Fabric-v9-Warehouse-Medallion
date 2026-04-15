CREATE TABLE [Retail_External].[StoreDailyOpenHours] (

	[StoreDailyOpenHoursID] int NULL, 
	[StoreID] varchar(10) NULL, 
	[TransDate] datetime2(6) NULL, 
	[OpenTime] decimal(13,2) NULL, 
	[CloseTime] decimal(13,2) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[ChangedBy] varchar(10) NULL, 
	[IsOpen] int NULL, 
	[DlvyDay] int NULL
);