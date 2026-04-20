CREATE TABLE [wholesale_pricing_afi].[DiscountRates] (

	[dradcode] char(3) NULL, 
	[dradiscls] char(2) NULL, 
	[dradisc1] numeric(6,4) NULL, 
	[dradisc2] numeric(6,4) NULL, 
	[dradisc3] numeric(6,4) NULL, 
	[dradisc4] numeric(6,4) NULL, 
	[dradisc5] numeric(6,4) NULL, 
	[dradisc6] numeric(6,4) NULL, 
	[dradisc7] numeric(6,4) NULL, 
	[drasdate] datetime2(6) NULL, 
	[draedate] datetime2(6) NULL, 
	[commaudit] bit NULL, 
	[usra] varchar(30) NULL, 
	[dtea] datetime2(6) NULL, 
	[usrc] varchar(30) NULL, 
	[dtec] datetime2(6) NULL, 
	[acrec] char(1) NULL
);