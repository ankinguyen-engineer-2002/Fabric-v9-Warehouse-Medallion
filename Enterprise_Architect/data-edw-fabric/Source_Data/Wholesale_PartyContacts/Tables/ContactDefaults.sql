CREATE TABLE [Wholesale_PartyContacts].[ContactDefaults] (

	[pcbPartyID] int NULL, 
	[pcbLocationID] int NULL, 
	[pcbDepartment] char(5) NULL, 
	[pcbContactType] char(5) NULL, 
	[pcbContactID] int NULL, 
	[pcbIsBuyerDefault] bit NULL, 
	[pcbIsReceivingDefault] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[pcbIsStoreDefault] bit NULL, 
	[pcbIsCustomerServiceDefault] bit NULL, 
	[pcbIsPrimaryOwnerDefault] bit NULL, 
	[pcbIsWarrantyDefault] bit NULL
);