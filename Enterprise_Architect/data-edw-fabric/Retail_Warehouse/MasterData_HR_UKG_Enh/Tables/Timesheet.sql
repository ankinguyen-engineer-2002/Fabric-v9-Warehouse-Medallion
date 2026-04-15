CREATE TABLE [MasterData_HR_UKG_Enh].[Timesheet] (

	[SegmentID] int NOT NULL, 
	[EmployeeNumber] varchar(10) NOT NULL, 
	[LocationID] varchar(10) NULL, 
	[WorkDate] date NULL, 
	[TimeIn] datetime2(6) NULL, 
	[TimeOut] datetime2(6) NULL, 
	[WorkHours] decimal(18,2) NULL, 
	[PayCodeID] int NOT NULL, 
	[PayCodeName] varchar(50) NULL, 
	[TaskID] int NULL, 
	[TaskCodeName] varchar(500) NULL, 
	[TaskCodeDescription] varchar(500) NULL, 
	[Wage] decimal(18,2) NULL, 
	[ApprovedByManager] bit NOT NULL, 
	[SegmentPaycodeIndex] int NOT NULL,
	[DataSource] [varchar](5) NOT NULL
);