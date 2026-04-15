CREATE     PROCEDURE [dbo].[Usp_Refresh_Retail_Enh]
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN 

EXEC [Retail_Sales_Enh].[usp_Update_SalesOrderProductInfo];

EXEC [Retail_Sales_Enh].[usp_Update_SalesAssociateCommission];

EXEC [Retail_Sales_Enh].[usp_Update_SalesOrderLine];

EXEC [Retail_Sales_Enh].[usp_Update_SalesOrderLineHistory];  

EXEC [Retail_Sales_Enh].[usp_Update_SalesOrderHeader];

EXEC [Retail_Sales_Enh].[usp_SalesOrderHistQueue];

EXEC [Retail_Sales_Enh].[usp_SalesOrderCloses];

EXEC [Retail_Sales_Enh].[usp_ProtectionPlanTrans_Insert];

EXEC [Retail_Sales_Enh].[usp_Update_StoreTraffic];

EXEC [Retail_Sales_Enh].[usp_Update_CreditApplication];

EXEC [Retail_Sales_Enh].[usp_Update_CreditReview];

EXEC [Retail_Sales_Enh].[usp_Update_SalesOrderFulfillment];

END