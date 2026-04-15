CREATE VIEW CustomerOrders_AFI_Wrk.v_CreditCodes
AS
SELECT [Crcde] AS CreditCode
      ,[Crdsc] AS [Description]
      ,[Crdid] AS CreditCodeID
      ,[acmFinanceCode] AS FinanceCode
      ,[acmApplyToCommission] AS ApplyToCommission
      ,[acmAccrualCredit] AS AccrualCredit
      ,[acmDateEntered] AS DateEntered
      ,[acmUserEntered] AS UserEntered
      ,[acmSpecialChargeCode] AS SpecialChargeCode
      ,[acmACREC] AS ActiveRecord
      ,[acmSalesTaxFlag] AS SalesTaxFlag
      ,[acmTypeCode] AS TypeCode
      ,[acmAllocationCode] AS AllocationCode
      ,[acmCommissionAdjFlag] AS CommissionAdjFlag
      ,[acmVolumeDiscountFlag] AS VolumeDiscountFlag
      ,[acmNoShowDiscountFlag] AS NoShowDiscountFlag
      ,[acmOpenField1Flag] AS SurchargeFlag
      ,[acmCOAAllowanceFlag] AS COAAllowanceFlag
      ,[acmOpenField2Flag] AS OpenField2Flag
      ,[acmDFIDiscountFlag] AS DFIDiscountFlag 
FROM [$(Source_Data)].[Wholesale_Codis_AFI].[ACRDMAS]