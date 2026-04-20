CREATE TABLE [Retail_Miniapps].[TrafficRequests] (

	[operation] varchar(10) NULL, 
	[TrafficRequestsID] int NULL, 
	[LocationID] varchar(10) NULL, 
	[TransDate] datetime2(6) NULL, 
	[TransHour] int NULL, 
	[SubmittedBy] varchar(10) NULL, 
	[RequestDate] datetime2(6) NULL, 
	[OriginalCount] decimal(18,2) NULL, 
	[RequestedCount] decimal(18,2) NULL, 
	[RecordedGuests] decimal(18,2) NULL, 
	[CaptureRate] decimal(18,4) NULL, 
	[CaptureRateLastYear] decimal(18,4) NULL, 
	[Average] decimal(18,4) NULL, 
	[ChangedBy] varchar(10) NULL, 
	[ChangeDate] datetime2(6) NULL, 
	[ChangeCount] decimal(18,2) NULL, 
	[Closed] varchar(10) NULL
);