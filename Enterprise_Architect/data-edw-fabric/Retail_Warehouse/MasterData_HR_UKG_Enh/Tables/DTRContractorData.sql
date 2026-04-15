CREATE TABLE [MasterData_HR_UKG_Enh].[DTRContractorData] (

	[ID] [int] NOT NULL,
	[LocationID] [int] NULL,
	[EntryTypeID] [int] NULL,
	[TransDate] [date] NULL,
	[TransDateKey] [int] NULL,
	[RegularCost] [decimal](18,2) NULL,
	[OvertimeCost] [decimal](18,2) NULL,
	[RegularHours] [decimal](13,2) NULL,
	[OvertimeHours] [decimal](13,2) NULL,
	[Pieces] [decimal](13,2) NULL,
	[ModifiedDate] [datetime2](3) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[TaskCodeID] [varchar](100) NULL,
	[ContractorTaskTypeID] [int] NULL,
	[DataSource] [varchar](5) NOT NULL
);