CREATE TABLE [wholesale_pricing_afi].[PriceCodeArchive] (

	[PriceCodeArchiveId] int NULL, 
	[pcoPccode] char(6) NULL, 
	[pcoPcdesc] varchar(30) NULL, 
	[pcoAshfreight] char(1) NULL, 
	[pcoMilfreight] char(1) NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL, 
	[pcoCurrencyCode] char(3) NULL, 
	[pcoDefaultBasePrice] char(1) NULL, 
	[pcoIncludeVAT] varchar(10) NULL, 
	[ArchiveStatus] char(1) NULL, 
	[StatusDate] datetime2(6) NULL, 
	[UserId] varchar(30) NULL, 
	[ReasonCode] char(6) NULL, 
	[ReasonDescription] varchar(15) NULL, 
	[UserNote] varchar(75) NULL, 
	[HistoryFlag] char(1) NULL
);