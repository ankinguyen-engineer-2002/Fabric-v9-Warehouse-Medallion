CREATE TABLE [MasterData_HR_UKG_Enh].[ProcessedPaycodesErrors] (

	[ReportDate] date NULL, 
	[EmployeeNumber] varchar(10) NOT NULL, 
	[SegmentID] int NOT NULL, 
	[ApplyDate] date NULL, 
	[StartDateTime] datetime2(3) NULL, 
	[EndDateTime] datetime2(3) NULL, 
	[PayCodeID] int NOT NULL, 
	[WorkHours] [decimal](18,2) NULL, 
	[Wage] decimal(18,2) NULL, 
	[SegmentPaycodeIndex] int NOT NULL, 
	[doesMatchFully] bit NULL, 
	[doesMatchPartially] bit NULL,
	[DataSource] varchar(5) NOT NULL
);