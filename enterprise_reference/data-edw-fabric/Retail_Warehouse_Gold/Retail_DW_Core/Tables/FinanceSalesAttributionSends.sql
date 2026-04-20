CREATE TABLE [Retail_DW_Core].[FinanceSalesAttributionSends] (

	[SendID] varchar(200) NULL, 
	[EventDate] date NULL, 
	[EventDateTime] datetime2(6) NULL, 
	[EmailName] varchar(255) NULL, 
	[EmailAddress] varchar(320) NULL, 
	[CreationDate] datetime2(6) NULL, 
	[Store] int NULL
);