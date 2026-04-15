CREATE TABLE [Retail_Miniapps].[Staff] (

	[ID] varchar(14) NOT NULL, 
	[LOC] varchar(20) NULL, 
	[NAME] varchar(50) NULL, 
	[RF_MESSAGING] varchar(21) NULL, 
	[RF_USER] varchar(21) NULL, 
	[SEC] varchar(21) NULL, 
	[TYPE] varchar(26) NULL, 
	[DFATYPE] int NULL, 
	[DFA_active] int NULL, 
	[PSWD] varchar(20) NULL, 
	[people_id] int NULL, 
	[lastdate] datetime2(6) NULL, 
	[active_status] bit NULL, 
	[CreatedDate] datetime2(6) NULL, 
	[CreatedBy] varchar(20) NULL, 
	[ChangedDate] datetime2(6) NULL, 
	[ChangedBy] varchar(20) NULL
);