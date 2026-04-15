CREATE TABLE [masterdata_hr_ukg].[Jobs] (

	[jobCode] varchar(20) NULL, 
	[countryCode] varchar(10) NULL, 
	[title] varchar(50) NULL, 
	[isActive] bit NULL, 
	[jobFamilyCode] varchar(20) NULL, 
	[longDescription] varchar(100) NULL, 
	[jobEEOCategory] varchar(10) NULL, 
	[jobGroup] varchar(10) NULL, 
	[flsaTypeCode] varchar(10) NULL, 
	[key] int NULL, 
	[dwLoadDateTime] datetime2(6) NULL, 
	[dataSource] varchar(10) NULL
);