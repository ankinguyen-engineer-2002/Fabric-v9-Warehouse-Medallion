CREATE TABLE [masterdata_hr_ukg_dsg].[changelog] (

	[id] int NULL, 
	[LogDate] datetime2(6) NULL, 
	[EmployeeNumber] varchar(8000) NULL, 
	[FirstName] varchar(8000) NULL, 
	[LastName] varchar(8000) NULL, 
	[FieldName] varchar(8000) NULL, 
	[OldValue] varchar(8000) NULL, 
	[NewValue] varchar(8000) NULL
);