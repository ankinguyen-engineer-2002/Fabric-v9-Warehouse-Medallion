
CREATE   proc [dbo].[usp_RefreshCustomerOrders_AFI] AS 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_DropConstraints] 'Wholesale_Warehouse'


EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','CreditCodes'   --Good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','DashboardValueList'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','ExtendedOrder'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OpenOrderAddress'   -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OpenOrderComments'   --good

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OpenOrderConsumerAddress'  -- 	good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OpenOrderDetail'      --  good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OpenOrderDiscounts'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OpenOrderExtendedItem'     --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OpenOrderHeader'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OrderArrivalCode'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OrderArrivalGroup'   --Good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OrderAuditDetail'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OrderAuditHeader'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OrderCancellationReasonCode'   -- good

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OrderSchedule'   --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','OrderTypeCode'  -- 	good

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','RequestDateChangeAudit'      --  good

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','RequestDateChangeCode'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','RouteZoneControl'     --good

--EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','SchedulerControl'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','TermsCode'  --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','WarehouseFillRequest'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','CustomerOrders_AFI','WarehouseMaster'  --good
GO


