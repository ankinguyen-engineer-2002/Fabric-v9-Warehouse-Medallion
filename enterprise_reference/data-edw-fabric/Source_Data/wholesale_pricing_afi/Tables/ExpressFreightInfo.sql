CREATE TABLE [wholesale_pricing_afi].[ExpressFreightInfo] (

	[CustomerNumber] decimal(8,0) NULL, 
	[ItemNumber] varchar(15) NULL, 
	[ItemClass] char(4) NULL, 
	[Length] decimal(5,0) NULL, 
	[Width] decimal(5,0) NULL, 
	[Height] decimal(5,0) NULL, 
	[Charge] decimal(10,0) NULL, 
	[DateAdded] datetime2(6) NULL, 
	[UserAdded] char(10) NULL, 
	[ProgramAdded] char(10) NULL, 
	[DateChanged] datetime2(6) NULL, 
	[UserChanged] varchar(20) NULL, 
	[ProgramChanged] varchar(10) NULL
);