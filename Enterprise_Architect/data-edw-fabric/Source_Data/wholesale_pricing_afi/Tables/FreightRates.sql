CREATE TABLE [wholesale_pricing_afi].[FreightRates] (

	[fraFcode] char(3) NULL, 
	[fraWhse] char(3) NULL, 
	[fraFrtcls] char(2) NULL, 
	[fraFrghtd] numeric(12,3) NULL, 
	[fraFrghtp] numeric(3,3) NULL, 
	[fraFbascd] char(1) NULL, 
	[fraFfrmvl] numeric(12,3) NULL, 
	[fraFtovl] numeric(12,3) NULL, 
	[fraFminim] numeric(12,2) NULL, 
	[fraFzone] char(5) NULL, 
	[fraFseqno] char(4) NULL, 
	[fraSdate] datetime2(6) NULL, 
	[fraEdate] datetime2(6) NULL, 
	[commaudit] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL
);