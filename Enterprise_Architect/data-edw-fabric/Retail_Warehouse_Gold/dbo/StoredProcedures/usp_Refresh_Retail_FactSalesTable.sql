CREATE PROCEDURE [dbo].[usp_Refresh_Retail_FactSalesTable] 
AS

BEGIN 

EXEC [Retail_DW_Core].[usp_Update_FactProtectionPlanSalesTrans];
 
EXEC [Retail_DW_Core].[usp_Update_FactProtectionPlanSalesTransToSalesDetailTrans];
 
EXEC [Retail_DW_Core].[usp_Update_FactSalesOrderTrans];
 
EXEC [Retail_DW_Core].[usp_Update_FactSalesOrderTransToSalesDetailTrans];

EXEC [Retail_DW_Core].[usp_Update_FactSalesDetailTrans];

END