Create Procedure dbo.Usp_Refresh_MasterData_Warehouse
 as
-- Drop contstraints created by semantic models (they will still exist in the model on the PowerBI layer)
EXEC [$(ETL_Framework)].[DW_Developer].[usp_DropConstraints] 'MasterData_Warehouse'

---- GeographicData 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'MasterData_Warehouse','GeographicData','CountryMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'MasterData_Warehouse','GeographicData','CountyMaster' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'MasterData_Warehouse','GeographicData','MsaMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'MasterData_Warehouse','GeographicData','StateMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'MasterData_Warehouse','GeographicData','ZipCode'  
