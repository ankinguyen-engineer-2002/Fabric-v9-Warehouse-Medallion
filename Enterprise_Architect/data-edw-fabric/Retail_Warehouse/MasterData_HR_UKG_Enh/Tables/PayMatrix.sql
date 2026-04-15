CREATE TABLE [MasterData_HR_UKG_Enh].[PayMatrix] (

	[PayMatrixID] [bigint] NULL,
	[TimeID] [bigint] NULL,
	[SourceLocationID] [int] NULL,
	[SourceTaskCodeID] [int] NULL,
	[SourcePayCodeID] [int] NULL,
	[SourceTimeCodeID] [varchar](50) NULL,
	[Hours] [decimal](18,2) NULL,
	[PayAmount] [decimal](18,2) NULL,
	[TransDate] [datetime2](6) NULL,
	[TransDateKey] [int] NULL,
	[PayCodeID] [int] NULL,
	[TaskCodeID] [int] NULL,
	[TimeCodeID] [int] NULL,
	[ApprovedByManager] [bit] NULL,
	[DataSource] [varchar](5) NOT NULL
);