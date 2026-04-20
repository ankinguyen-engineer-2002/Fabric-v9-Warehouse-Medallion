CREATE TABLE [Wholesale_Marketing].[AdNoticeDetail] (

	[Andkey] int NOT NULL, 
	[Andforeignkey] int NOT NULL, 
	[Anditemnumber] varchar(17) NOT NULL, 
	[Andquantity] int NOT NULL, 
	[Usra] varchar(32) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(32) NULL, 
	[Dtec] datetime2(6) NULL, 
	[Andwarehouse] char(3) NOT NULL, 
	[Andapproved] bit NOT NULL, 
	[Andcomments] varchar(502) NOT NULL, 
	[Andchangeneeded] bit NOT NULL, 
	[Andqtyavailable] int NULL, 
	[Andatpdate] datetime2(6) NULL, 
	[Andpreviousqty] int NULL, 
	[Anddpresponded] bit NOT NULL
);