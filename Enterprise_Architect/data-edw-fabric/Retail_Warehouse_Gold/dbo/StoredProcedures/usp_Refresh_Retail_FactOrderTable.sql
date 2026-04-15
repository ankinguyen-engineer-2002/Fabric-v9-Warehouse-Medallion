CREATE PROCEDURE [dbo].[usp_Refresh_Retail_FactOrderTable]
AS

BEGIN 

EXEC [Retail_DW_Core].[usp_Update_FactOrderDetail];
 
EXEC [Retail_DW_Core].[usp_Update_FactSalesOrderHeader];
 
EXEC [Retail_DW_Core].[usp_Update_FactSalesOrderCloses];

EXEC [Retail_DW_Core].[usp_Update_FactOrderFulfillment];

END