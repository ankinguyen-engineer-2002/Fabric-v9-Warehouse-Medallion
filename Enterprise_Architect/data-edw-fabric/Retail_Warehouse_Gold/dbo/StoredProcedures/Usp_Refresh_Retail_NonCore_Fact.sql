CREATE   PROCEDURE [dbo].[Usp_Refresh_Retail_NonCore_Fact] 
AS

BEGIN 

EXEC [Retail_DW_NonCore].[usp_Update_FactOOMSchedulePerformance]
 
EXEC [Retail_DW_NonCore].[usp_Update_FactOOMSchedulePerformanceDetails]

EXEC [Retail_DW_NonCore].[usp_FactInvActivitySummary_Insert]

EXEC [Retail_DW_NonCore].[usp_InventoryDailyOpen_Insert]

EXEC [Retail_DW_NonCore].[usp_InventoryDailySummary_Insert]

END