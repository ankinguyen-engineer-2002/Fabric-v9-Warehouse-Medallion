CREATE   VIEW [Retail_DW_Core_Wrk].[v_SMQQ_FactLocationMaster] AS
SELECT [LocationID]
     , [LocationType]
     , [ServiceLocationID]
     , [StockLocationID]
     , [ShipLocationID]
     , [StoreBrandID]
     , [LocationName]
     , [Address1]
     , [City]
     , [PostalCodeID]
     , [TotalSquareFeet]
     , [ProductiveSquareFeet]
     , [OpenDate]
     , [SameStoreDate]
     , IIF(CAST(GETDATE() AS DATE) > DATEADD(DAY, 455, OpenDate), 'COMP', 'NEW') AS CompFlag
     
     -- Store = LocationMaster[LocationID] & " - " & LocationMaster[LocationName]
     , CONCAT(CAST([LocationID] AS VARCHAR(10)), ' - ', [LocationName]) AS Store

FROM [$(Source_Data)].[Retail_Corporate].[LocationMaster] AS lm
WHERE lm.LocationType = 'ST'
GO

