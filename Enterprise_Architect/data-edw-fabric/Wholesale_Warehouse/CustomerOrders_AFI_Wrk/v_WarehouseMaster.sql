 CREATE VIEW [CustomerOrders_AFI_Wrk].[v_WarehouseMaster]
AS
SELECT [wmaWarehouse]
      ,[wmaLocationId]
      ,[wmaIntransitWarehouse]
      ,[wmaSiteId]
      ,[wmaMROSiteId]
      ,[wmaWarehouseType]
      ,[wmaWarehouseOrderGroup]
      ,[wmaWarehouseSourceId]
      ,[wmaRouteType]
      ,[wmaDefaultPortId]
      ,[wmaControlled]
      ,[wmaPrinterName]
      ,[wmaZebraPrinter]
      ,[wmaSendBolsToManu]
      ,[wmaOrderReleaseMin]
      ,[wmaOrderReleaseMinType]
      ,[wmaDefaultShipId]
      ,[wmaSortOrder]
      ,[wmaAsOverhead]
      ,[wmaAsFreight]
      ,[wmaContainerDirectWhse]
      ,[acrec]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[wmaWhereMade]
      ,[wmaManufacturingSite]
      ,[wmaSellableWarehouse]
 

FROM	[$(Source_Data)].[Wholesale_Codis_AFI].[AshleyWarehouseMaster] 
    
   


