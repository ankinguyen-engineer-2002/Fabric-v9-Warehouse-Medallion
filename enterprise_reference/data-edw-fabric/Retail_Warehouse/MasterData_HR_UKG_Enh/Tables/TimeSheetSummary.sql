CREATE TABLE [MasterData_HR_UKG_Enh].[TimeSheetSummary] (

	[SourceDataID] [int] NULL,
	[TransDateKey] [int] NULL,
	[SourceLocationID] [int] NULL,
	[PayCodeID] [int] NULL,
	[TaskCodeID] [int] NULL,
	[TimeCodeID] [int] NULL,
	[TotalTime] [decimal](18,2) NULL,
	[TotalCost] [decimal](18,2) NULL,
	[Benefit] [decimal](18,4) NULL,
	[IsExternal] [bit] NULL,
	[ApprovedByManager] [bit] NULL,
	[DataSource] [varchar](5) NOT NULL
);