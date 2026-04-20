CREATE TABLE [masterdata_hr_ukg].[Locations] (

	[locationCode] varchar(10) NULL, 
	[description] varchar(50) NULL, 
	[isActive] bit NULL, 
	[addressLine1] varchar(50) NULL, 
	[addressLine2] varchar(50) NULL, 
	[city] varchar(50) NULL, 
	[state] varchar(20) NULL, 
	[zipOrPostalCode] varchar(10) NULL, 
	[countryCode] varchar(3) NULL, 
	[locationGLSegment] varchar(10) NULL, 
	[dwLoadDateTime] datetime2(6) NULL, 
	[dataSource] varchar(3) NULL
);