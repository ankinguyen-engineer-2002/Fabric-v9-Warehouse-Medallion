CREATE PROCEDURE [dbo].[Usp_Refresh_Retail_FactCreditTable] 
AS

BEGIN 

EXEC [Retail_DW_Core].[usp_Update_FactCreditReview];
 
EXEC [Retail_DW_Core].[usp_Update_FactCustomerFinanceActivity];

END