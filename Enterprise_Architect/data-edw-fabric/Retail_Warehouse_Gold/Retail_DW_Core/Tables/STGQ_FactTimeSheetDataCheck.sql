CREATE TABLE [Retail_DW_Core].[STGQ_FactTimeSheetDataCheck] (

	[LocationID] varchar(8000) NULL, 
	[TransDate] date NULL, 
	[EmployeeNumber] varchar(8000) NULL, 
	[FirstName] varchar(8000) NULL, 
	[LastName] varchar(8000) NULL, 
	[JobID] int NULL, 
	[JobName] varchar(8000) NULL, 
	[EmpStatus] varchar(8000) NULL, 
	[EmpHourlySalary] varchar(8000) NULL, 
	[TransHour] time(6) NULL, 
	[MinutesWorked] int NULL, 
	[ApprovedByManager] bit NULL, 
	[TimeSheetIsOpen] int NULL, 
	[TrafficTransHour] int NULL, 
	[Traffic] decimal(18,4) NULL, 
	[TrafficIsOpen] int NULL
);