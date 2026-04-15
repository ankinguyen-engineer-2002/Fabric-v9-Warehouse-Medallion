CREATE TABLE [Retail_Dart].[WFM_Timesheet] (

	[SegmentID] int NOT NULL, 
	[WorkShiftID] int NOT NULL, 
	[EmployeeNumber] varchar(10) NOT NULL, 
	[ApplyDate] date NULL, 
	[StartDateTime] datetime2(6) NULL, 
	[EndDateTime] datetime2(6) NULL, 
	[PayCodeID] int NOT NULL, 
	[WorkHours] float NULL, 
	[Wage] decimal(18,2) NULL, 
	[LocationID] varchar(10) NULL, 
	[ProjectID] int NULL, 
	[ApprovedByManager] bit NOT NULL, 
	[SegmentPaycodeIndex] int NOT NULL
);