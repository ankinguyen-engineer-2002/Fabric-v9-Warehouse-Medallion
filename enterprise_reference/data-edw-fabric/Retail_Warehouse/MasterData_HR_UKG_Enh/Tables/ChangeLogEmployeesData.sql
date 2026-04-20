CREATE TABLE [MasterData_HR_UKG_Enh].[ChangeLogEmployeesData] (

	[ChangeLogID] bigint NOT NULL, 
	[LogDate] datetime2(3) NOT NULL, 
	[PersonDetailKey] int NOT NULL, 
	[FieldID] int NOT NULL, 
	[OldValue] varchar(100) NULL, 
	[NewValue] varchar(100) NULL, 
	[DataSource] varchar(5) NOT NULL
);