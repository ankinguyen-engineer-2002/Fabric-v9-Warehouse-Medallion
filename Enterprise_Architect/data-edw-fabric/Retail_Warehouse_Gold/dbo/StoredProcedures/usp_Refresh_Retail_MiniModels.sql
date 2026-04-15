CREATE     PROCEDURE [dbo].[usp_Refresh_Retail_MiniModels] 
AS

BEGIN 

-- Lease Analysis Report Table Updates
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_DimAcimaStaffedStores'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_DimDate'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_DimDayMap'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_DimFinanceProviderMapping'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_DimLocation'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_DimSalesperson'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_FactLeaseOppsAttempts'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_FactLeaseTranscationCounts'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_FactLeaseWrittenSales'
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','LEAS_FactTraffic'

-- Three Year Protection Plan Report Table Updates
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','TYPP_FactProtectionPlan'

-- -- Appointment Sales report Table Updates
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_DimConvWeeks'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_DimLocMap'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_DimRollups'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_DimSalesperson'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_FactAppointments'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_FactFutureAppointments'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_FactOrders'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_FactSalespersonID'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','APPS_FactTraffic'

-- -- Staffing Model report Table Updates
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_FactEmployeeHistory'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_FactRSADetails' 
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_FactRSAHours'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_FactTraffic'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_FactTrafficBudget'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_FactTransactions'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_Stores_Summary'
-- EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_SummarizedTrafficBudget'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','SMQQ_S2G_Proj_Bucket'


-- Staffing To Guest report Table Updates
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactCurrentRSA'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactEmployeeHistory'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactEmployeeHours'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactLocation'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactStoreBudgetHC'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactStores'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactTimeSheetDataCheck'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactTimesheets'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactTraffic'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactTrafficBudget'
--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Retail_Warehouse','Retail_DW_Core','STGQ_FactTrafficBudgetLocations'


END