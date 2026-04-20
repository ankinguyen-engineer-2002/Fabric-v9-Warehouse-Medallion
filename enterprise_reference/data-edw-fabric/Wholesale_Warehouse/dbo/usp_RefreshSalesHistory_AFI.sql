

CREATE proc usp_RefreshSalesHistory_AFI AS 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_DropConstraints] 'Wholesale_Warehouse'


EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','InvoiceConsumerInformation'   --Good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','InvoiceDetail'   --good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','InvoiceDetailProperties'   --good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','InvoiceHeader'   -- good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','InvoiceValueAddedTax'   --good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','ItemComments'  -- 	good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','OrderComments'      --  good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','OrderHistory'  --good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','ShippedHistoryCommAdjustment'  --good

EXEC  [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','ShippedHistoryDiscounts'     --good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','ShippedHistoryExpressServiceTracking'  -- good

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView]'Wholesale_Warehouse','SalesHistory_AFI','SpecialCharges'  --good
