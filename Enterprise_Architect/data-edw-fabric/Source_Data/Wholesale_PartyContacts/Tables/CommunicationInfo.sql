CREATE TABLE [Wholesale_PartyContacts].[CommunicationInfo] (

	[pcpLocationID] int NULL, 
	[pcpPartyId] int NULL, 
	[pcpContactType] char(5) NULL, 
	[pcpContactId] int NULL, 
	[pcpSequenceNumber] int NULL, 
	[pcpDepartment] char(5) NULL, 
	[pcpCommunicationValueExt] varchar(15) NULL, 
	[pcpCommunicationType] char(5) NULL, 
	[pcpCommunicationValue] varchar(90) NULL, 
	[pcpIsDefault] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[pcpLastUserChanged] varchar(35) NULL, 
	[pcpActiveEndDate] datetime2(6) NULL
);