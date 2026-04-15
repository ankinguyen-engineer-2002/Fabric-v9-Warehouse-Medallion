CREATE TABLE [masterdata_hr_ukg_dsg].[timesheet] (

	[operation] varchar(8000) NULL, 
	[SegmentID] int NULL, 
	[EmployeeNumber] varchar(8000) NULL, 
	[LocationID] varchar(8000) NULL, 
	[WorkDate] datetime2(6) NULL, 
	[TimeIn] datetime2(6) NULL, 
	[TimeOut] datetime2(6) NULL, 
	[WorkHours] float NULL, 
	[PayCodeID] int NULL, 
	[PayCodeName] varchar(8000) NULL, 
	[TaskID] int NULL, 
	[TaskCodeName] varchar(8000) NULL, 
	[TaskCodeDesc] varchar(8000) NULL, 
	[Wage] decimal(18,2) NULL, 
	[ApprovedByManager] bit NULL, 
	[SegmentPaycodeIndex] int NULL
);