CREATE TABLE [Wholesale_Quality_AFI].[ARPDETL] (

	[RPKEY] int NULL, 
	[ITMSEQ] numeric(2,0) NULL, 
	[ITEMNO] varchar(15) NULL, 
	[ITEMFG] char(1) NULL, 
	[QTY] numeric(4,0) NULL, 
	[STDCST] numeric(6,2) NULL, 
	[BASPRC] numeric(6,2) NULL, 
	[SHPFLG] char(1) NULL, 
	[PCKFLG] char(1) NULL, 
	[PCKBAD] char(8) NULL, 
	[PCKDTE] numeric(8,0) NULL, 
	[PCKTME] numeric(6,0) NULL, 
	[PCKUSR] varchar(10) NULL, 
	[ICRGTYP] char(1) NULL, 
	[ISHPCST] numeric(6,2) NULL
);