CREATE TABLE [enterprise_ods].[datefile] (

	[ltd_DropTimestamp] datetime2(6) NULL, 
	[ltd_ID] int NULL, 
	[ltd_mergeIgnore] bit NULL, 
	[ltd_count1] bigint NULL, 
	[dfiInpsdt] datetime2(6) NULL, 
	[dfiInpsmn] varchar(8000) NULL, 
	[dfiInpsyr] varchar(8000) NULL, 
	[dfiInpswk] varchar(8000) NULL, 
	[dfiYear] int NULL, 
	[dfiMonth] int NULL, 
	[dfiWeek] int NULL, 
	[usra] varchar(8000) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(8000) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] varchar(8000) NULL, 
	[dfiMarket] varchar(8000) NULL, 
	[dfiYearWeek] varchar(8000) NULL, 
	[dfiCharDate] varchar(8000) NULL, 
	[dfiYearPeriod] varchar(8000) NULL, 
	[dfiMapicsDate] decimal(38,18) NULL, 
	[dfiHoliday] varchar(8000) NULL
);

