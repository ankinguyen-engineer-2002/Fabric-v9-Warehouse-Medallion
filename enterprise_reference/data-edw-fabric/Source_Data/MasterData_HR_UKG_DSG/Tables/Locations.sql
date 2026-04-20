CREATE TABLE [MasterData_HR_UKG_DSG].[Locations] (

	[locationCode] varchar(6) NULL, 
	[description] varchar(25) NULL, 
	[isActive] bit NULL, 
	[addressLine1] varchar(33) NULL, 
	[addressLine2] varchar(25) NULL, 
	[city] varchar(16) NULL, 
	[state] varchar(2) NULL, 
	[zipOrPostalCode] varchar(5) NULL, 
	[countryCode] varchar(3) NULL, 
	[locationGLSegment] varchar(6) NULL, 
	[dwLoadDateTime] datetime2(6) NULL, 
	[dataSource] varchar(3) NULL
);