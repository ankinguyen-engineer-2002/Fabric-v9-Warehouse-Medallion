CREATE TABLE [Retail_Dart].[Staff] (

	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[StaffID] varchar(50) NOT NULL, 
	[PeopleID] int NULL, 
	[Name] varchar(100) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[EmployeeNbr] varchar(50) NULL, 
	[ServiceLocationID] varchar(50) NULL, 
	[StaffTypeID] varchar(50) NULL, 
	[LanguageCode] int NULL, 
	[DateCreated] datetime2(6) NULL, 
	[DateChanged] datetime2(6) NULL
);