CREATE TABLE [Wholesale_PartyContacts].[ContactBase] (

	[pccLocationID] int NULL, 
	[pccPartyID] int NULL, 
	[pccContactType] char(5) NULL, 
	[pccContactID] int NULL, 
	[pccJobTitle] varchar(30) NULL, 
	[pccDepartment] char(5) NULL, 
	[pccIsDefault] bit NULL, 
	[pccNetworkUserID] varchar(25) NULL, 
	[pccAS400UserID] varchar(10) NULL, 
	[pccProgramAdded] varchar(30) NULL, 
	[pccActiveEndDate] datetime2(6) NULL, 
	[pccAdGuid] varchar(40) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[pccLastUserChanged] varchar(35) NULL, 
	[pccDefaultLanguage] char(8) NULL, 
	[pccForecastPlannerID] varchar(40) NULL
);