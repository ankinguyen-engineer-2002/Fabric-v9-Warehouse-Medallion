CREATE TABLE [Manufacturing_Inventory_AFI].[TFRHDR] (

	[HACREC] char(1) NULL, 
	[HTFRNO] varchar(9) NULL, 
	[HFHOUS] char(3) NULL, 
	[HTHOUS] char(3) NULL, 
	[HSHDTE] decimal(8,0) NULL, 
	[HLDDTE] decimal(8,0) NULL, 
	[HDLDTE] decimal(8,0) NULL, 
	[HCANCL] char(1) NULL, 
	[HSTATS] char(1) NULL, 
	[HBPRNT] char(1) NULL, 
	[HBPDTE] decimal(8,0) NULL, 
	[HPOST] char(1) NULL, 
	[HORIG] char(1) NULL, 
	[HTRCMT] varchar(30) NULL, 
	[HARRDT] decimal(8,0) NULL, 
	[HTFRTP] char(2) NOT NULL, 
	[HDDCFL] char(1) NOT NULL, 
	[HORDNO] char(10) NOT NULL, 
	[HORDTP] char(3) NULL, 
	[HDDAFL] char(1) NULL
);