CREATE Procedure [dbo].[Usp_RefreshCustomers] as

EXEC [$(ETL_Framework)].[DW_Developer].[usp_DropConstraints] 'Wholesale_Warehouse'
---- Customers  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Customers','AccountMaster'  

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Customers','CustomerCredit' 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Customers','DeliveryWindow'  

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Customers','ExtendedCustomerProfile' 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Customers','ServiceRepGroup' 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Customers','ServiceRepID' 

EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Customers','ShippingLocations' 
GO

