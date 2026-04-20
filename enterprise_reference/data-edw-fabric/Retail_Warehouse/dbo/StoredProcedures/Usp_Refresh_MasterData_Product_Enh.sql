CREATE PROCEDURE [dbo].[Usp_Refresh_MasterData_Product_Enh]
AS

BEGIN 

EXEC [MasterData_Product_Enh].[usp_Refresh_ProductInfo];

END