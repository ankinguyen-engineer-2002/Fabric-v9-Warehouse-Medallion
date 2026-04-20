CREATE   Procedure [dbo].[Usp_Refresh_Pricing_AFI] as
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','BuyGroupDefault'   
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','BuyGroupMaster'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','BuyGroupMember'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','BuyGroupPrice'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','CommissionClass'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','CommissionCodes'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','CommissionRates'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','CustomerPricingSetup'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','DiscountClass'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','DiscountCodes'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','DiscountRates' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','ExpressFreightInfo'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','FreightClass'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','FreightCodes'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','FreightRates'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','FreightZones'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','PriceCode' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','PriceExceptions' 
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','PriceList'  
EXEC [$(ETL_Framework)].[DW_Developer].[usp_RefreshCuratedTableFromView] 'Wholesale_Warehouse','Pricing_AFI','SalesClass'  
GO


