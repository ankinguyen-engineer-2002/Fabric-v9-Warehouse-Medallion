CREATE TABLE [Masterdata_Onesource].[OSContactjoin] (

	[Oscjcontactid] int NOT NULL, 
	[Oscjlicenseeid] int NULL, 
	[Oscjlocationid] int NULL, 
	[Oscjcontacttype] varchar(52) NOT NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL
);