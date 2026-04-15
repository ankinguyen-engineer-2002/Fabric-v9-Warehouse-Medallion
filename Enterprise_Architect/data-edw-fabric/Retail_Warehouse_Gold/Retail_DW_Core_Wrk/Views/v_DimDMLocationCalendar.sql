CREATE VIEW [Retail_DW_Core_Wrk].[v_DimDMLocationCalendar]
AS
SELECT
	lm.StoreID
    , lc.LocationKey
    , dm.DateID  AS TransDate
    , lc.OpenTime
    , lc.CloseTime
    , lc.IsOpen AS TYIsOpen
    , ly.IsOpen AS LYIsOpen
    , ny.IsOpen AS NYIsOpen
    , lc.IsOpen * ly.IsOpen AS TYComp
    , lc.IsOpen * ny.IsOpen AS LYComp
    , CAST(CONVERT(VARCHAR(8), lc.TransDate, 112) AS INT) AS TransDateKey
    , CAST(CONVERT(VARCHAR(8), dm.LYDate, 112) AS INT) AS LYDateKey
    , CAST(CONVERT(VARCHAR(8), dm.NYDate, 112) AS INT) AS NYDateKey
    , lc.IsDelivery
    , lm.SameStoreDate
FROM [Retail_DW_Core].[DimStoreLocationCalendar] AS lc
INNER JOIN [Retail_DW_Core].[DimDate] AS dm
ON dm.DateID = lc.TransDate
INNER JOIN [Retail_DW_Core].[DimStoreLocationCalendar] AS ly
ON ly.LocationKey = lc.LocationKey
AND ly.TransDate = dm.LYDate
INNER JOIN [Retail_DW_Core].[DimStoreLocationCalendar] AS ny
ON ny.LocationKey = lc.LocationKey
AND ny.TransDate = dm.NYDate
INNER JOIN [$(Retail_Warehouse)].[MasterData_Retail_Ent].[StoreLocation] AS lm
ON lm.StoreID = lc.StoreID;
GO

