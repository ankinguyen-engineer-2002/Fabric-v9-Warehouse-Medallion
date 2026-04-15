CREATE TABLE [Wholesale_Marketing].[CRMAdvertisingFunds] (

	[Cafid] int NOT NULL, 
	[Cafregioncode] char(3) NOT NULL, 
	[Cafrepid] char(5) NULL, 
	[Cafdivisioncode] char(1) NOT NULL, 
	[Cafaccountnumber] char(8) NULL, 
	[Cafshipto] char(4) NULL, 
	[Cafcreateddate] datetime2(6) NULL, 
	[Cafmarketdate] datetime2(6) NULL, 
	[Cafmodifieddate] datetime2(6) NULL, 
	[Cafmodifiedby] varchar(42) NULL, 
	[Cafadfundsselecteddivision] varchar(52) NULL, 
	[Cafadfundsvelocitydriver] varchar(102) NULL, 
	[Caftypeoffundname] varchar(102) NULL, 
	[Cafapprovalstatuscode] int NOT NULL, 
	[Cafapprovalstatusdescr] varchar(102) NULL, 
	[Cafadfundsrequested] decimal(18,3) NULL, 
	[Cafadfundsapproved] decimal(18,3) NULL, 
	[Cafnew_comments] varchar(4002) NULL, 
	[Cafnew_specialdiscountcodeifapplicable] varchar(27) NULL, 
	[Cafnew_adfundsname] varchar(102) NULL
);