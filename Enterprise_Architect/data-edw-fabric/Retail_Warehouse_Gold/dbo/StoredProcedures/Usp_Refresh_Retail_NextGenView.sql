CREATE     PROCEDURE [dbo].[Usp_Refresh_Retail_NextGenView] 
AS 

BEGIN

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'CartDetail';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'CartHeader';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'Epsilon_Bounces';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'Favourites';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'FinanceProvider';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'LeadAppointments';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'Leads';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'Leadsv2';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'OrdersNextGen_PBI';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'Relationship';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'Relationship_Assignee';

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core' , 'StorisAppUser';


END