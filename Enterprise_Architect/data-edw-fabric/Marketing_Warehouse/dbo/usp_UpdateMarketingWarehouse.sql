
create Procedure dbo.Usp_UpdateMarketingWarehouse as


---- Email_Marketing  

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','DimDate' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','DimMessage'   ,'Date','Date',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','UniqueAccountDateLevel'   ,'ActionTimestamp','ActionTimestamp',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueClicks'   ,'Email_Date','Email_Date',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Marketing_Warehouse','Email_Marketing','UniqueEmails'  ,'Email_Date','Email_Date',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','UniquePromotionalCampaign'  ,'[Delivered Start Date]','[Delivered Start Date]',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','UniquePromotionalSegment'     ,'Delivered_Startdate','Delivered_Startdate',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','UniquePromotionalSegmentClickers'  ,'Delivered_Startdate','Delivered_Startdate',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','UniqueTransactionalCampaign'  ,'Email_Date','Email_Date',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','UniqueTransactionalSegment'  ,'Email_Date','Email_Date',3
EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateCuratedTableFromView_DateRange] 'Marketing_Warehouse','Email_Marketing','UniqueTransactionalSegmentClickers' ,'Email_Date','Email_Date',3