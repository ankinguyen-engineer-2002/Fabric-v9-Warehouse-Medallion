CREATE TABLE [Wholesale_PartyContacts].[Locations] (

	[pltLocationID] int NULL, 
	[pltPartyID] int NULL, 
	[pltAddressID] int NULL, 
	[pltDescription] varchar(50) NULL, 
	[pltLocationType] char(5) NULL, 
	[pltAddressVerificationDate] datetime2(6) NULL, 
	[pltReverificationFrequency] int NULL, 
	[pltOutsideSourceType] char(5) NULL, 
	[pltOutsideSourceLocation] varchar(20) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[pltActiveEndDate] datetime2(6) NULL, 
	[pltShortDescription] varchar(25) NULL
);