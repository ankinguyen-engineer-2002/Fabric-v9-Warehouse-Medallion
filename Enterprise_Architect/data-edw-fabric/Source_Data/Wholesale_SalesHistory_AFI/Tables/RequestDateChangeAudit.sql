CREATE TABLE [Wholesale_SalesHistory_AFI].[RequestDateChangeAudit] (

	[OrderNumber] char(7) NULL, 
	[CustomerNumber] numeric(18,0) NULL, 
	[ShipToNumber] char(4) NULL, 
	[OldRequestDate] numeric(18,0) NULL, 
	[NewRequestDate] numeric(18,0) NULL, 
	[Reason] char(2) NULL, 
	[ChangeDate] numeric(18,0) NULL, 
	[ChangeItem] numeric(18,0) NULL, 
	[ChangeUser] varchar(10) NULL
);