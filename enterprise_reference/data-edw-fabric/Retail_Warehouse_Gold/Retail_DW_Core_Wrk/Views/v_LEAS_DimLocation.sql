-- Auto Generated (Do not modify) 0FA7F66799D302048C977356CBEC45E4EAA42B57478A33183A2B06BCCAC9A4FF
CREATE     VIEW [Retail_DW_Core_Wrk].[v_LEAS_DimLocation] AS
SELECT DISTINCT
       LM.[StoreID],
       [LocationKey],
       [LocationType],
       [ServiceLocationID],
       [StockLocationID],
       [ShipLocationID],
       [StoreBrandID],
       CASE WHEN LG.StoreID IS NULL THEN 0 ELSE 1 END AS AFHSFlag,
       [LocationName],
       CONCAT(CONCAT(LM.StoreID, '-'), LM.LocationName) AS Store,
       [Address1],
       [City],
       [PostalCodeID],
       --,[RegionID]
       --,[RegionName]
       --,[DistrictID]
       --,[DistrictName]
       --,[HasTrafficCounter]
       [TotalSquareFeet],
       [ProductiveSquareFeet],
       [SoftOpenDate],
       [GrandOpenDate],
       IIF(CAST(GETDATE() AS DATE) > DATEADD(DAY, 455, SoftOpenDate), 'COMP', 'NEW') AS CompFlag
FROM [Retail_DW_Core].[DimStoreLocation] AS LM
    LEFT JOIN
        (
            SELECT DISTINCT
                   StoreID
            FROM [Retail_DW_Core].[DimStoreLocationGroup]
            WHERE LocationGroupID = 'AFHS'
        ) LG
        ON LM.StoreID = LG.StoreID