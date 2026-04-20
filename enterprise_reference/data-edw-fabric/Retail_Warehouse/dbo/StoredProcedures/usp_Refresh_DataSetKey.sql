CREATE PROCEDURE [dbo].[usp_Refresh_DataSetKey]
AS

BEGIN

	EXEC [MasterData_Retail_Ent].[usp_Refresh_DataSetKey];

END
GO

