CREATE TABLE [wholesale_productsourcing_afi].[poauditlog] (

	[poaId] int NULL, 
	[poaOrderNum] varchar(8000) NULL, 
	[poaDateTime] datetime2(6) NULL, 
	[poaUserID] varchar(8000) NULL, 
	[poaItemNum] varchar(8000) NULL, 
	[poaFieldName] varchar(8000) NULL, 
	[poaValue] varchar(8000) NULL, 
	[poaTransactionType] varchar(8000) NULL, 
	[poaProcessStatus] varchar(8000) NULL, 
	[poaPreviousValue] varchar(8000) NULL, 
	[poaRevisionNum] int NULL, 
	[poaMemo] varchar(8000) NULL, 
	[poaAction] varchar(8000) NULL, 
	[poaApplication] varchar(8000) NULL
);

