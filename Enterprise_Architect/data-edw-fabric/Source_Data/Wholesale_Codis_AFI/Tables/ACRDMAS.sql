CREATE TABLE [Wholesale_Codis_AFI].[ACRDMAS] (

	[Crcde] char(3) NULL, 
	[Crdsc] varchar(30) NULL, 
	[Crdid] char(1) NULL, 
	[acmFinanceCode] char(3) NULL, 
	[acmApplyToCommission] char(1) NULL, 
	[acmAccrualCredit] char(1) NULL, 
	[acmDateEntered] datetime2(6) NULL, 
	[acmUserEntered] varchar(10) NULL, 
	[acmSpecialChargeCode] char(1) NULL, 
	[acmACREC] char(1) NULL, 
	[acmSalesTaxFlag] char(1) NULL, 
	[acmTypeCode] varchar(10) NULL, 
	[acmAllocationCode] varchar(10) NULL, 
	[acmCommissionAdjFlag] char(1) NULL, 
	[acmVolumeDiscountFlag] char(1) NULL, 
	[acmNoShowDiscountFlag] char(1) NULL, 
	[acmOpenField1Flag] char(1) NULL, 
	[acmCOAAllowanceFlag] char(1) NULL, 
	[acmOpenField2Flag] char(1) NULL, 
	[acmDFIDiscountFlag] char(1) NULL
);