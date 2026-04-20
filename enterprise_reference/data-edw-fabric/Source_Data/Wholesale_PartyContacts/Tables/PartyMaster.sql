CREATE TABLE [Wholesale_PartyContacts].[PartyMaster] (

	[pymPartyID] int NULL, 
	[pymPartyName] varchar(35) NULL, 
	[pymCustomerNumber] char(8) NULL, 
	[pymVendorID] char(8) NULL, 
	[pymExportID] char(8) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[pymActiveEndDate] datetime2(6) NULL, 
	[pymPartyType] char(5) NULL, 
	[pymShortName] varchar(25) NULL
);