-- Auto Generated (Do not modify) B585F9039C89369FCDF2726D29DFD799CF3392B8B46EEE43206309A2F2908E49
CREATE VIEW [Retail_DW_Core_Wrk].[v_DimRollUps]
AS

WITH AGRLocations AS
(
	SELECT DISTINCT StoreID 
	FROM [Retail_DW_Core].[DimStoreLocationGroup]
	WHERE LocationGroupID IN ('ENVUT', 'WSEAI', 'EWFLA', 'EEFLA', 'EATLA', 'EARIZ','WCALC', 'WCALS', 'WCALN', 'WCALW', 'WCALE','EDIV','WDIV')
)

SELECT 
	lg.StoreID
    , CASE WHEN lg.StoreID = '090' THEN 'Worth & Co' ELSE lg.LocationGroupID END AS 'RollUp'
    , CASE WHEN lg.LocationGroupID IN ('NHOSTR', 'SHOSTR','EHOSTR', 'WHOSTR') THEN 'Division' -- Removed 'EDIV','WDIV' from Division by Mary
	  WHEN lg.LocationGroupID IN ('EDIV','WDIV') THEN 'VP' -- Added 'EDIV','WDIV' in VP by Mary
	  WHEN lg.LocationGroupID LIKE '%-D' THEN 'Marketing' -- Added by Mary
	  WHEN lm.LocationName Not Like '%LIQUIDATION%'  and  lg.LocationGroupID IN 
	  ( 
		--'NDET'
		--, 'NOHIO'
		'NDETO'
		, 'NINLOU'
		, 'NECHI'
		, 'NWCHI'
		, 'NNCHI'
		, 'NSCHI'
		--, 'NMEM'
		--, 'NNASH'
		, 'NTENN'
		, 'NSTL'
		--, 'SNOLA'
		, 'NNOLA'
		, 'SSANAU'
		, 'SHOUSR'
		, 'SDALLS'
		, 'SWTEX'
		, 'SETEX'
		, 'SOUTLE'
		, 'ENVUT'
		, 'WSEAI'
		, 'EWFLA'
		, 'EEFLA'
		, 'EATLA'
		, 'EARIZ'
		, 'WCALC'
		, 'WCALS'
		, 'WCALN'
		, 'WCALW'
		, 'WCALE'
		,'EDIV'
		,'WDIV'
	  ) THEN 'Region'                                
	  WHEN lg.LocationGroupID IN ('SCNorth', 'SCSouth', 'SCWest') THEN 'SleepRegion'
      WHEN lg.LocationGroupID IN ('ALSTR', 'AFHS') THEN 'AllStores'
      WHEN lg.LocationGroupID IN ('600', 'ETEAM') THEN 'Virtual'
	  WHEN lg.LocationGroupID IN ('090', 'Worth') THEN 'Worth & Co' --Added for Worth and Co group filter
	  WHEN lg.LocationGroupID IN ('RED','RED / YELLOW','YELLOW') THEN 'Finance'
	  ELSE NULL END AS RollUpFilter
	  --AGR Red or AGR Yellow Store Identifier
	, CASE WHEN lg.StoreID IN (SELECT * FROM AGRLocations) THEN 'AGR_Yellow' 
	  ELSE 'AGR_Red' END AS StoreType 
	, concat(RIGHT(REPLICATE('0', 3) + CAST(lg.StoreID  AS VARCHAR(3)), 3),   
     '-',lm.LocationName) AS StoreName
FROM [Retail_DW_Core].[DimStoreLocationGroup] lg
LEFT JOIN [Retail_DW_Core].[DimStoreLocation] AS lm
ON lg.StoreID = lm.StoreID
WHERE lm.LocationType = 'ST';