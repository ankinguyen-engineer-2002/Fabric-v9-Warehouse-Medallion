CREATE TABLE [Wholesale_Invoicing_AFI].[TSCMADJ] (

	[CDHInvoiceNumber] numeric(9,0) NULL, 
	[CDHOrderNumber] char(7) NULL, 
	[CDHItemNumber] varchar(15) NULL, 
	[CDHItemSequence] numeric(7,0) NULL, 
	[CDHCommissionAdjustmentCode] char(3) NULL, 
	[CDHExceptionAmount] numeric(12,2) NULL, 
	[CDHExceptionID] numeric(7,0) NULL, 
	[CDHPriceCode] char(6) NULL
);