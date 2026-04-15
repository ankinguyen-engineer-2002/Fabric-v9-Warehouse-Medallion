CREATE TABLE [MasterData_HR_UKG_Enh].[ProcessedSegmentErrors] (

	[ReportDate] date NULL, 
	[SegmentID] int NOT NULL, 
	[WorkShiftID] int NOT NULL, 
	[EmployeeNumber] varchar(10) NOT NULL, 
	[StartDateTime] datetime2(3) NULL, 
	[EndDateTime] datetime2(3) NULL, 
	[ApplyDate] date NULL, 
	[DurationInSeconds] int NULL, 
	[SegmentTypeID] int NULL, 
	[InProgress] bit NULL, 
	[LocationID] varchar(10) NULL, 
	[ProjectID] int NULL,
	[DataSource] varchar(5) NOT NULL
);