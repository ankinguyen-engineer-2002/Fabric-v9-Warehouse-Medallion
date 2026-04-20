CREATE TABLE [masterdata_security].[groupprofile] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[grpSecurityId] int NULL, 
	[grpGroupId] varchar(8000) NULL, 
	[grpDescription] varchar(8000) NULL, 
	[grpFlagDev] bit NULL, 
	[grpFlagStage] bit NULL, 
	[grpFlagProd] bit NULL, 
	[grpFlagBeta] bit NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL
);

