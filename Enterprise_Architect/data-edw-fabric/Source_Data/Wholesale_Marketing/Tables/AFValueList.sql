CREATE TABLE [Wholesale_Marketing].[AFValueList] (

	[Afvlid] int NULL, 
	[Afvlvaluetype] varchar(30) NULL, 
	[Afvlvaluecode] varchar(55) NULL, 
	[Afvlvaluedescription] varchar(105) NULL, 
	[Afvlvaluedefault] bit NULL, 
	[Afvlvaluesortorder] int NULL, 
	[Usra] varchar(35) NULL, 
	[Dtea] datetime2(6) NULL, 
	[Usrc] varchar(35) NULL, 
	[Dtec] datetime2(6) NULL, 
	[Active] bit NULL, 
	[Afvldivisioncode] varchar(205) NULL
);