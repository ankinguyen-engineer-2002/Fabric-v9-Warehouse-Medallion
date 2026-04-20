CREATE TABLE [Retail_DW_Core].[STGQ_FactTimesheets] (

	[TimeSheetID] int NULL, 
	[PayCodeName] varchar(8000) NULL, 
	[TaskCodeName] varchar(8000) NULL, 
	[LocationID] varchar(8000) NULL, 
	[TransDate] date NULL, 
	[Year] int NULL, 
	[TimeIn] datetime2(6) NULL, 
	[TimeOut] datetime2(6) NULL, 
	[EmployeeNumber] varchar(8000) NULL, 
	[JobName] varchar(8000) NULL, 
	[FirstName] varchar(8000) NULL, 
	[LastName] varchar(8000) NULL, 
	[Name] varchar(8000) NULL
);