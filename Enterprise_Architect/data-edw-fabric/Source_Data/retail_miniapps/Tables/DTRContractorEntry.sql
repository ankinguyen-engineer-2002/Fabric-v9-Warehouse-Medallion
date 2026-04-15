CREATE TABLE [Retail_Miniapps].[DTRContractorEntry] (

	[Operation] varchar(50) NULL, 
	[EntryTypeID] int NOT NULL, 
	[EntryTypeDesc] varchar(100) NOT NULL, 
	[DepartmentID] int NULL, 
	[RegCostFlag] bit NULL, 
	[OTCostFlag] bit NULL, 
	[RegHoursFlag] bit NULL, 
	[OTHoursFlag] bit NULL, 
	[PiecesFlag] bit NULL, 
	[TaskCodeID] varchar(100) NULL, 
	[ContractorTaskTypeID] int NULL, 
	[ActiveCode] bit NULL
);