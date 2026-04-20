CREATE TABLE [Retail_Corporate].[Warranty] (

	[Operation] varchar(15) NULL, 
	[CompanyID] varchar(50) NOT NULL, 
	[DateChanged] datetime2(6) NULL, 
	[DateCreated] datetime2(6) NULL, 
	[Description] varchar(50) NULL, 
	[LaborPeriod] varchar(10) NULL, 
	[LaborPeriodStart] varchar(10) NULL, 
	[LaborPeriodType] varchar(10) NULL, 
	[LastBatchID] int NULL, 
	[PartsPeriod] varchar(10) NULL, 
	[PartsPeriodStart] varchar(10) NULL, 
	[PartsPeriodType] varchar(10) NULL, 
	[RecStatus] char(1) NULL, 
	[SourceID] varchar(50) NOT NULL, 
	[Type] varchar(10) NULL, 
	[VendorID] varchar(50) NULL, 
	[WarrantyID] varchar(50) NOT NULL
);