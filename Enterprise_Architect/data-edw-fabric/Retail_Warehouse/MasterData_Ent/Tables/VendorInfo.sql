CREATE TABLE [MasterData_Ent].[VendorInfo] (

	[VendorID] varchar(20) NOT NULL, 
	[VendorName] varchar(50) NULL, 
	[VendorClass] varchar(10) NULL, 
	[Address1] varchar(255) NULL, 
	[Address2] varchar(255) NULL, 
	[City] varchar(50) NULL, 
	[State] varchar(50) NULL, 
	[PostalCode] varchar(50) NOT NULL, 
	[CountryID] varchar(5) NULL
);