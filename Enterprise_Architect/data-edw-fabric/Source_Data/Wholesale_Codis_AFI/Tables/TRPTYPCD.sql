CREATE TABLE [Wholesale_Codis_AFI].[TRPTYPCD] (

	[ttcTripType] char(1) NULL, 
	[ttcTripTypeDescription] varchar(25) NULL, 
	[ttcSpecialHandling] char(1) NULL, 
	[ttcUserDefined] char(1) NULL, 
	[ttcAddTimeStamp] datetime2(6) NOT NULL, 
	[ttcAddUser] varchar(10) NULL, 
	[ttcChangeTimeStamp] datetime2(6) NOT NULL, 
	[ttcChangeUser] varchar(10) NULL, 
	[ttcTransportMethod] char(2) NULL, 
	[ttcResourceCapability] varchar(12) NULL, 
	[ttcDeliveryModeDefault] char(3) NULL, 
	[ttcDeliveryCategory] varchar(10) NULL
);