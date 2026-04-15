CREATE TABLE [Retail_Corporate].[StoreDailyOpenHours] (

	[StoreDailyOpenHoursID] int NOT NULL, 
	[StoreID] varchar(50) NOT NULL, 
	[TransDate] datetime2(6) NOT NULL, 
	[OpenTime] numeric(13,2) NULL, 
	[CloseTime] numeric(13,2) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[ChangedBy] varchar(50) NULL, 
	[IsOpen] int NOT NULL, 
	[DlvyDay] int NULL
);