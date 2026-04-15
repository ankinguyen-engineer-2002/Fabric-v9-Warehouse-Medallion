CREATE TABLE [Wholesale_Codis_AFI].[RequestDateChangeCodes] (

	[Rdcreasoncode] char(2) NULL, 
	[Rdcdescription] varchar(52) NULL, 
	[Rdcadddate] decimal(8,0) NULL, 
	[Rdcadduser] varchar(12) NULL, 
	[Rdcchangedate] decimal(8,0) NULL, 
	[Rdcchangeuser] varchar(12) NULL, 
	[Rdcstatus] char(1) NULL, 
	[Rdccancelflag] char(1) NULL, 
	[Rdcavailabletoashleydirect] char(1) NULL, 
	[Rdcashleydirectdescription] varchar(27) NULL
);