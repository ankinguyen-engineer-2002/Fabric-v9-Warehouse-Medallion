CREATE TABLE [Wholesale_Customers].[CustomerControl] (

	[CCVApplicationName] varchar(10) NOT NULL, 
	[CCVEventID] varchar(15) NOT NULL, 
	[CCVCompanyNumber] decimal(2,0) NOT NULL, 
	[CCVCustomerNumber] decimal(8,0) NOT NULL, 
	[CCVShiptoNumber] varchar(4) NOT NULL, 
	[CCVAllShiptos] decimal(1,0) NOT NULL, 
	[CCVValue] varchar(35) NOT NULL, 
	[CCVDescription] varchar(50) NOT NULL, 
	[Usra] varchar(30) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(30) NULL, 
	[Dtec] datetime2(6) NULL
);