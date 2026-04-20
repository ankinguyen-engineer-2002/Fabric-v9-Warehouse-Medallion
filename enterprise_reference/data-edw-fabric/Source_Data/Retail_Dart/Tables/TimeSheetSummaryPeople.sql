CREATE TABLE [Retail_Dart].[TimeSheetSummaryPeople] (

	[PeopleID] bigint NULL, 
	[SourceDataID] int NULL, 
	[TransDateKey] int NULL, 
	[LocationKey] int NULL, 
	[PayCodeID] int NULL, 
	[TaskCodeID] int NULL, 
	[TimeCodeID] int NULL, 
	[TotalTime] decimal(18,2) NULL, 
	[TotalCost] decimal(18,2) NULL, 
	[Benefit] decimal(18,4) NULL, 
	[IsExternal] bit NULL
);