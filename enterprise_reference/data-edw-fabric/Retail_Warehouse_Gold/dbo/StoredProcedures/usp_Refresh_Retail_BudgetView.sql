CREATE PROCEDURE [dbo].[usp_Refresh_Retail_BudgetView]
AS

BEGIN

/* OLS SCRIPT
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactSalesBudget';
 
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactTrafficandCloseBudget';

-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactFinancialBudget';
*/

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactFinancialBudget';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactSalesBudget';
 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FactTrafficandCloseBudget';

END