CREATE TABLE [MasterData_HR_UKG_Enh].[TimeSheetHours] (
	[EmployeeNumber] [varchar](50) NOT NULL,
	[LocationID] [int] NOT NULL,
	[TransDateKey] [int] NOT NULL,
	[TransHour] [datetime2](3) NULL,
	[TimeIn] [datetime2](3) NULL,
	[TimeOut] [datetime2](3) NULL,
	[MinutesWorked] [int] NULL,
	[IsOpen] [int] NULL,
	[ApprovedByManager] [bit] NULL,
	[DataSource] [varchar](5) NOT NULL
);