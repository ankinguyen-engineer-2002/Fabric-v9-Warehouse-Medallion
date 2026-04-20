CREATE TABLE [masterdata_hr_ukg_dsg].[timesheetsummary] (

	[SourceDataID] int NULL, 
	[TransDateKey] int NULL, 
	[LocationKey] int NULL, 
	[PayCodeID] int NULL, 
	[TaskCodeID] int NULL, 
	[TimeCodeID] int NULL, 
	[TotalTime] decimal(18,2) NULL, 
	[TotalCost] decimal(18,2) NULL, 
	[Benefit] decimal(18,4) NULL, 
	[IsExternal] bit NULL, 
	[ApprovedByManager] bit NULL
);