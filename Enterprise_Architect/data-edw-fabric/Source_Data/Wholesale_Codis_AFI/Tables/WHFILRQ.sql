CREATE TABLE [Wholesale_Codis_AFI].[WHFILRQ] (

	[FLTRIPNO] int NOT NULL, 
	[FLHOUSE] char(3) NULL, 
	[FLCUBES] decimal(10,2) NULL, 
	[FLPRCCUBES] decimal(10,2) NULL, 
	[FLCUSNO] int NULL, 
	[FLSHPNO] char(4) NULL, 
	[FLRUSR] varchar(10) NULL, 
	[FLRDTE] datetime2(6) NOT NULL, 
	[FLUSRP] varchar(10) NULL, 
	[FLPDTE] datetime2(6) NULL, 
	[FLPROC] char(1) NULL
);