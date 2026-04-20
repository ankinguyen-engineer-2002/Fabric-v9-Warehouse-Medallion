CREATE TABLE [Retail_Miniapps].[PeopleRecords] (

	[Operation] varchar(50) NOT NULL, 
	[PeopleID] int NULL, 
	[PeopleType_ID] int NULL, 
	[EmployeeNumber] varchar(100) NULL, 
	[ActiveStatus] bit NULL, 
	[Email] varchar(200) NULL, 
	[CreatedDate] datetime2(6) NULL, 
	[SupID] varchar(50) NULL, 
	[FirstName] varchar(50) NULL, 
	[LastName] varchar(50) NULL, 
	[EmpStatus] char(5) NULL, 
	[EmpFTPT] char(5) NULL, 
	[HireDate] datetime2(6) NULL, 
	[LocationID] varchar(50) NULL, 
	[JobID] int NULL, 
	[DivisionID] int NULL, 
	[DepartmentID] int NULL, 
	[RegionID] int NULL, 
	[EmployeeTypeID] int NULL, 
	[SepDate] datetime2(6) NULL
);