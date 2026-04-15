CREATE TABLE [Wholesale_PartyContacts].[PartyBusinessRelationship] (

	[PbrParentPartyID] int NULL, 
	[PbrChildPartyID] int NULL, 
	[PbrBusinessRelationshipType] char(5) NULL, 
	[PbrRelationshipDescription] varchar(50) NULL, 
	[PbrIsDefault] bit NULL, 
	[PbrActiveEndDate] datetime2(6) NULL, 
	[Usra] varchar(30) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(30) NULL, 
	[Dtec] datetime2(6) NULL
);