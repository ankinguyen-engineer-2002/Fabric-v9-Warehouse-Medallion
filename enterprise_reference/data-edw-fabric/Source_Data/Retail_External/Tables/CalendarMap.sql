CREATE TABLE [Retail_External].[CalendarMap] (

	[Operation] char(5) NULL, 
	[ID] bigint NOT NULL, 
	[CalendarKey] varchar(20) NULL, 
	[Date] date NULL, 
	[DOW] varchar(10) NULL, 
	[WK] int NULL, 
	[YEAR] int NULL, 
	[MONTH] varchar(10) NULL, 
	[WEDATE] datetime2(6) NULL, 
	[QTR] int NULL, 
	[LYD] date NULL, 
	[CALM] date NULL, 
	[QWK] int NOT NULL, 
	[PAY] int NULL
);