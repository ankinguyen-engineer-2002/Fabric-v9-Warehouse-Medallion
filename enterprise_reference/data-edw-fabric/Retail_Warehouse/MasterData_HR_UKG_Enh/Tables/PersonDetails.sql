CREATE TABLE [MasterData_HR_UKG_Enh].[PersonDetails] (

	[PersonDetailKey] int NOT NULL, 
	[DataSource] varchar(5) NOT NULL, 
	[EmployeeID] varchar(20) NULL, 
	[Username] varchar(100) NULL, 
	[FirstName] varchar(100) NULL, 
	[MiddleName] varchar(100) NULL, 
	[LastName] varchar(100) NULL, 
	[PreferredName] varchar(100) NULL, 
	[FormerName] varchar(100) NULL, 
	[EmailAddress] varchar(100) NULL, 
	[EmailAddressAlternate] varchar(100) NULL, 
	[DateChanged] datetime2(3) NULL, 
	[DateCreated] datetime2(3) NULL, 
	[NamePrefix] varchar(25) NULL, 
	[NameSuffix] varchar(25) NULL, 
	[Generation] varchar(100) NULL
);