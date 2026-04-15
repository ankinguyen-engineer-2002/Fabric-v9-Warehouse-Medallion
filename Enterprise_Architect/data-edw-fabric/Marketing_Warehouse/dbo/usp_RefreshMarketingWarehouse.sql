CREATE Procedure dbo.Usp_Refresh_Marketing_Warehouse as


--- Drop contstraints created by semantic models (they will still exist in the model on the PowerBI layer)
EXEC [$(ETL_Framework)].[DW_Developer].[usp_DropConstraints] 'Marketing_Warehouse'

---- Email_Marketing 

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','AccountLevel'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','DimDate' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','DimMessage'  
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','DollarPerAudiencePromotional'  
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','DollarPerAudienceTransactional'  
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','TotalAccountDateLevel'  
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','TotalPromotionalCampaign' 
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','TotalPromotionalSegments' 
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','TotalTransactionalCampaign'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','TotalTransactionalSegment'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueAccountDateLevel'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueClicks'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueEmails' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniquePromotionalCampaign' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniquePromotionalSegment'    
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniquePromotionalSegmentClickers' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueTransactionalCampaign' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueTransactionalSegment' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueTransactionalSegmentClickers' 