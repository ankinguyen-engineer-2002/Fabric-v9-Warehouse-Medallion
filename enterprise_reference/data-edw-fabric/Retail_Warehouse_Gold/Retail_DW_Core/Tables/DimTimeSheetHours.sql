CREATE TABLE [Retail_DW_Core].[DimTimeSheetHours] (
	[EmployeeNumber] [varchar](50) NOT NULL,
	[LocationID] [int] NOT NULL,
	[LocationKey] [int] NOT NULL,
	[TransDate] [date] NOT NULL,
	[TransHour] [datetime2](3) NULL,
	[TimeIn] [datetime2](3) NULL,
	[TimeOut] [datetime2](3) NULL,
	[MinutesWorked] [int] NULL,
	[IsOpen] [int] NULL,
	[ApprovedByManager] [bit] NULL,
	[DataSource] [varchar](5) NOT NULL
);