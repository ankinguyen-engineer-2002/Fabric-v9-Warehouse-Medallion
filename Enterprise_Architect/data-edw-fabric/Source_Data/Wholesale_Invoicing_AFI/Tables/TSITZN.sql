CREATE TABLE [Wholesale_Invoicing_AFI].[TSITZN] (

	[HPOINVNO] numeric(9,0) NULL, 
	[HPOORDNO] char(7) NULL, 
	[HPOITEMNO] varchar(15) NULL, 
	[HPOITEMSQ] numeric(7,0) NULL, 
	[HPOSERIAL] numeric(15,0) NULL, 
	[HPOPONO] char(7) NULL, 
	[HPOCUSNO] numeric(7,0) NULL, 
	[HPOSHPNO] char(4) NULL, 
	[HPOINVDT] numeric(8,0) NULL, 
	[HPODTPAID] datetime2(6) NULL, 
	[HPOVENDOR] char(8) NULL, 
	[HPOSLSOFF] varchar(10) NULL, 
	[HPOCNTRYO] char(5) NULL, 
	[HPOSTDMTP] numeric(9,2) NULL, 
	[HPOESOVPC] numeric(5,4) NULL, 
	[HPOESOVPR] numeric(9,2) NULL, 
	[HPOTCUBES] numeric(8,2) NULL, 
	[HPOCUBES] numeric(7,2) NULL, 
	[HPOLSTMND] datetime2(6) NULL, 
	[HPOLSTMNU] varchar(10) NULL
);