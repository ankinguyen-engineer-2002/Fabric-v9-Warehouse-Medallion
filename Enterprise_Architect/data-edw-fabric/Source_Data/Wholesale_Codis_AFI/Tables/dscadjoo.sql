CREATE TABLE [Wholesale_Codis_AFI].[dscadjoo] (

	[dcoOrderNumber] char(7) NULL, 
	[dcoItemSequence] numeric(12,0) NULL, 
	[dcoDiscountType] char(1) NULL, 
	[dcoDiscountAdjustmentCode] char(3) NULL, 
	[dcoItemNumber] varchar(15) NULL, 
	[dcoAmount] numeric(12,2) NULL, 
	[dcoRatioAmount] numeric(12,2) NULL, 
	[dcoDiscountPercent] numeric(8,4) NULL, 
	[dcoExceptionID] numeric(12,0) NULL, 
	[dcoDiscountCode] char(3) NULL, 
	[dcoDiscountSalesClass] char(2) NULL
);