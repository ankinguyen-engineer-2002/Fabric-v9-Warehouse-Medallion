CREATE TABLE [MasterData_Retail_Ent].[Staff] (

	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[StaffID] varchar(50) NOT NULL, 
	[PeopleID] int NULL, 
	[StaffName] varchar(100) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[EmployeeNumber] varchar(50) NULL, 
	[ServiceLocationID] varchar(50) NULL, 
	[StaffTypeID] varchar(50) NULL, 
	[LanguageCode] int NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateChanged] datetime2(6) NULL
);