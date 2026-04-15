CREATE TABLE [Wholesale_SalesHistory_AFI_Wrk].[RequestDateChangeAudit] (

	[Ordernumber] char(7) NULL, 
	[Customernumber] decimal(8,0) NULL, 
	[Shiptonumber] char(4) NULL, 
	[Oldrequestdate] decimal(8,0) NULL, 
	[Newrequestdate] decimal(8,0) NULL, 
	[Reason] char(2) NULL, 
	[Changedate] decimal(8,0) NULL, 
	[Changeitem] decimal(6,0) NULL, 
	[Changeuser] varchar(12) NULL
);