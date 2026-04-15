CREATE TABLE [Masterdata_Onesource].[OSContact] (

	[Osccontactid] int NOT NULL, 
	[Oscfirstname] varchar(102) NULL, 
	[Osclastname] varchar(102) NULL, 
	[Oscnickname] varchar(52) NULL, 
	[Oscsalutation] varchar(12) NULL, 
	[Oscofficephone] varchar(27) NULL, 
	[Oscextension] varchar(12) NULL, 
	[Osccellphone] varchar(27) NULL, 
	[Oscfax] varchar(17) NULL, 
	[Oscemail] varchar(52) NULL, 
	[Oscprimary] bit NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL
);