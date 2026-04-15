CREATE TABLE [Retail_Dart].[ProcessedSegmentErrors] (

	[ReportDate] date NULL, 
	[SegmentID] int NOT NULL, 
	[WorkShiftID] int NOT NULL, 
	[EmployeeNumber] varchar(10) NOT NULL, 
	[StartDateTime] datetime2(6) NULL, 
	[EndDateTime] datetime2(6) NULL, 
	[ApplyDate] date NULL, 
	[DurationInSeconds] int NULL, 
	[SegmentTypeID] int NULL, 
	[InProgress] bit NULL, 
	[LocationID] varchar(10) NULL, 
	[ProjectID] int NULL
);