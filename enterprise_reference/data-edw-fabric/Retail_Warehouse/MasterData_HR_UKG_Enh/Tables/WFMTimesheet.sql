CREATE TABLE [MasterData_HR_UKG_Enh].[WFMTimesheet] (

	[SegmentID] [int] NOT NULL,
	[WorkShiftID] [int] NOT NULL,
	[EmployeeNumber] [varchar](10) NOT NULL,
	[ApplyDate] [date] NULL,
	[StartDateTime] [datetime2](3) NULL,
	[EndDateTime] [datetime2](3) NULL,
	[PayCodeID] [int] NOT NULL,
	[WorkHours] [decimal](18,2) NULL,
	[Wage] [decimal](18,2) NULL,
	[LocationID] [int] NULL,
	[ProjectID] [int] NULL,
	[ApprovedByManager] [bit] NOT NULL,
	[SegmentPaycodeIndex] [int] NOT NULL,
	[DataSource] [varchar](5) NOT NULL
);