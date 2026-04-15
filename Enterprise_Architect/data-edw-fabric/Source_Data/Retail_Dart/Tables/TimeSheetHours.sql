CREATE TABLE [Retail_Dart].[TimeSheetHours] (

	[EmployeeNumber] varchar(50) NOT NULL, 
	[LocationID] varchar(50) NOT NULL, 
	[TransDateKey] int NOT NULL, 
	[TransHour] datetime2(6) NULL, 
	[TimeIn] datetime2(6) NULL, 
	[TimeOut] datetime2(6) NULL, 
	[MinutesWorked] int NULL, 
	[IsOpen] int NULL, 
	[ApprovedByManager] bit NULL
);