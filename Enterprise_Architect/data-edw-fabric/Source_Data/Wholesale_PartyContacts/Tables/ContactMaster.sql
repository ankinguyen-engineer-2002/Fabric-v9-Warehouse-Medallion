CREATE TABLE [Wholesale_PartyContacts].[ContactMaster] (

	[pctContactID] int NULL, 
	[pctFullName] varchar(50) NULL, 
	[pctFirstName] varchar(25) NULL, 
	[pctMiddleName] varchar(25) NULL, 
	[pctLastName] varchar(25) NULL, 
	[pctPreferredName] varchar(20) NULL, 
	[pctPreferredLanguage] char(5) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[pctLastUserChanged] varchar(35) NULL, 
	[pctShortFullName] varchar(50) NULL
);