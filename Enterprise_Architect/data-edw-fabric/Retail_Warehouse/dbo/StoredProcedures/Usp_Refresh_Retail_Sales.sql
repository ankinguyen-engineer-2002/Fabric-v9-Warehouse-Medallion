CREATE PROCEDURE [dbo].[Usp_Refresh_Retail_Sales]
AS

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'CreditApplication';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'CreditReview';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'SalesAssociateCommission';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'SalesOrderProductInfo';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'SalesOrderLine';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'SalesOrderLineHistory';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'SalesOrderHeader';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'SalesOrderFulfillment';

EXEC [Retail_Traffic].[Usp_Refresh_OverrideTraffic]

EXEC [Retail_Traffic].[usp_Refresh_EnterpriseActualTraffic]

EXEC [Retail_Traffic].[Usp_Refresh_RealTimeTraffic]

EXEC [Retail_Traffic].[Usp_Refresh_StoreTraffic]

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'StoreTraffic';

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse', 'Retail_Sales', 'RegisteredGuest';

END