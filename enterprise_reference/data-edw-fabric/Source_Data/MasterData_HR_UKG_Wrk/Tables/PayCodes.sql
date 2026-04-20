CREATE TABLE [MasterData_HR_UKG_Wrk].[PayCodes] (

	[type] varchar(10) NULL, 
	[unit] varchar(10) NULL, 
	[visibleToTimecardSchedule] bit NULL, 
	[id] int NULL, 
	[name] varchar(50) NULL, 
	[shortName] varchar(50) NULL, 
	[combined] bit NULL, 
	[money] bit NULL, 
	[totals] bit NULL, 
	[excusedAbsence] bit NULL, 
	[wageMultiplier] decimal(3,2) NULL, 
	[wageAddition] decimal(3,2) NULL, 
	[addToTimecardTotal] bit NULL, 
	[visibleToUser] bit NULL, 
	[visibleToReports] bit NULL, 
	[checkAvailability] int NULL, 
	[scheduledHoursType] varchar(20) NULL, 
	[cascadingDuration] bit NULL, 
	[netDown] bit NULL, 
	[dwLoadDateTime] datetime2(6) NULL, 
	[dataSource] varchar(10) NULL
);