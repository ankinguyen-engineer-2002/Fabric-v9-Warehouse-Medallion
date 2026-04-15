CREATE TABLE [Retail_DW_Core].[DMTimeSheetHours] (

	[EmployeeNumber] varchar(50) NOT NULL, 
	[LocationID] varchar(50) NOT NULL, 
	[TransDate] date NOT NULL, 
	[TransHour] datetime2(3) NULL, 
	[MinutesWorked] int NULL, 
	[IsOpen] int NULL, 
	[ApprovedByManager] bit NULL
);