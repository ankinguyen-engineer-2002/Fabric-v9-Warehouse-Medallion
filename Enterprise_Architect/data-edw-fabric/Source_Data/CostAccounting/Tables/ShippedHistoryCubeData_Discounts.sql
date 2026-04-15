CREATE TABLE [CostAccounting].[ShippedHistoryCubeData_Discounts] (

	[FDCInvoiceNumber] numeric(9,0) NULL, 
	[FDCOrderNumber] varchar(10) NULL, 
	[FDCInvoiceDate] datetime2(6) NULL, 
	[FDCItemSequence] numeric(29,0) NULL, 
	[FDCDiscountType] char(3) NULL, 
	[FDCDiscountAdjustmentCode] char(3) NULL, 
	[FDCItemNumber] varchar(15) NULL, 
	[FDCAmount] numeric(29,6) NULL, 
	[FDCRatioAmount] numeric(29,6) NULL, 
	[FDCDiscountPercent] numeric(29,4) NULL, 
	[FDCExceptionID] numeric(29,0) NULL, 
	[FDCDiscountCode] char(3) NULL, 
	[FDCDiscountSalesClass] char(2) NULL, 
	[FDCAdjustmentAmount] numeric(29,2) NULL
);