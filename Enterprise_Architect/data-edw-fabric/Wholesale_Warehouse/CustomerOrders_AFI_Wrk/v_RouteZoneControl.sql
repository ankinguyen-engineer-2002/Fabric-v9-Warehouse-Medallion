CREATE VIEW [CustomerOrders_AFI_Wrk].[v_RouteZoneControl]
AS
SELECT  [rzcZone]
      ,[rzcWhse]
      ,[rzcRegion]
      ,[rzcOrderReleaseMinimum]
      ,[rzcTripType]
      ,[rzcRouteMethod]
  FROM [$(Source_Data)].[Wholesale_Codis_AFI].[RouteZoneControl]