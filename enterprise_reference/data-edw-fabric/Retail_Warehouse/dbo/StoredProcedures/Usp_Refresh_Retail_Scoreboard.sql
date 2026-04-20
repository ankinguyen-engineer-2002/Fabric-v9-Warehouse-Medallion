CREATE PROCEDURE [dbo].[Usp_Refresh_Retail_Scoreboard]
AS
BEGIN

EXEC [Retail_Sales_Enh].[usp_Update_SalespersonUPBoardHistory];

EXEC [Retail_Sales_Enh].[usp_Update_SalesPersonHourlyStats];

EXEC [Retail_Sales_Enh].[usp_Update_SalesPersonDailyStats];

EXEC [Retail_Sales_Enh].[usp_Update_ScoreboardActivity];

EXEC [Retail_Sales_Enh].[usp_Update_ScoreboardManagerNotes];

END