CREATE TABLE [Retail_OOM_Enh].[GLHist] (

	[Id] varchar(20) NOT NULL, 
	[ItemId] varchar(20) NOT NULL, 
	[ReferenceNumber] varchar(8000) NULL, 
	[Period] bigint NOT NULL, 
	[YearId] bigint NOT NULL, 
	[PostDate] datetime2(3) NOT NULL, 
	[PostTime] datetime2(3) NOT NULL, 
	[Operator] varchar(10) NOT NULL, 
	[HeaderComment] varchar(200) NULL, 
	[CustomerKey] varchar(50) NULL, 
	[CustomerType] varchar(10) NULL, 
	[Source] varchar(10) NOT NULL, 
	[TransDate] datetime2(3) NOT NULL, 
	[AccountNumber] varchar(50) NOT NULL, 
	[Debit] decimal(18,3) NOT NULL, 
	[Credit] decimal(18,3) NOT NULL, 
	[Remark] varchar(4000) NULL, 
	[AccountId] bigint NOT NULL, 
	[DateCreated] datetime2(3) NOT NULL
);