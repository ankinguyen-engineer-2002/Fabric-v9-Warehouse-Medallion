CREATE TABLE [Retail_Dart].[ProcessedPaycodesErrors] (

	[ReportDate] date NULL, 
	[EmployeeNumber] varchar(10) NOT NULL, 
	[SegmentID] int NOT NULL, 
	[ApplyDate] date NULL, 
	[StartDateTime] datetime2(6) NULL, 
	[EndDateTime] datetime2(6) NULL, 
	[PayCodeID] int NOT NULL, 
	[WorkHours] float NULL, 
	[Wage] decimal(18,2) NULL, 
	[SegmentPaycodeIndex] int NOT NULL, 
	[doesMatchFully] bit NULL, 
	[doesMatchPartially] bit NULL
);