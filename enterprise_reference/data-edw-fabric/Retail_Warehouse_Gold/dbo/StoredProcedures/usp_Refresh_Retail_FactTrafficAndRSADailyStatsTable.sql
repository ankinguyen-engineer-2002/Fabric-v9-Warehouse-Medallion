CREATE PROCEDURE [dbo].[usp_Refresh_Retail_FactTrafficAndRSADailyStatsTable] 
AS

BEGIN 

EXEC [Retail_DW_Core].[usp_Update_FactTraffic];

EXEC [Retail_DW_Core].[usp_Update_FactRSADailyStats];

EXEC [Retail_DW_Core].[usp_Update_FactScoreboardActivity];

EXEC [Retail_DW_Core].[usp_Update_FactScoreboardManagerNotes];

END