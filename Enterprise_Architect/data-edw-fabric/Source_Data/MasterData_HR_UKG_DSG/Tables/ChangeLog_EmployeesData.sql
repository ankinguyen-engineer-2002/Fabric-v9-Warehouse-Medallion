CREATE TABLE [MasterData_HR_UKG_DSG].[ChangeLog_EmployeesData] (

	[id] int NOT NULL, 
	[LogDate] datetime2(6) NOT NULL, 
	[PersonDetailKey] int NOT NULL, 
	[FieldID] int NOT NULL, 
	[OldValue] varchar(100) NULL, 
	[NewValue] varchar(100) NULL
);