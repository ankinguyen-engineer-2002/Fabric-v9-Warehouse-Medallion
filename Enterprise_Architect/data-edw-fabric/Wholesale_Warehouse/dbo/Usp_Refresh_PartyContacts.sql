CREATE   Procedure [dbo].[Usp_Refresh_PartyContacts] as
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','AddressMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','CommunicationInfo'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','ContactBase'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','ContactDefaults'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','ContactMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','ContactValueList'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','Locations'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','PartyMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','PartyContacts','ProfileDetail'  
GO