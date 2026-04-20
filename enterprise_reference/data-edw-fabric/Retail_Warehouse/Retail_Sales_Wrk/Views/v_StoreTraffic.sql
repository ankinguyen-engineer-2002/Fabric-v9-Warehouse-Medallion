-- Auto Generated (Do not modify) 681B69AD8B50E3EB4DAB93291A38304F4A9F5F83D05F8BCD3C973065B69B0E6E

CREATE          VIEW [Retail_Sales_Wrk].[v_StoreTraffic]
AS
-- Commented by Mary on 7 Jan 2026. 
-- WITH CTE_Traffic AS (
-- 	SELECT
-- 		dataSource AS DataSource
-- 		 --sttShopperTrakOrgID AS DeviceSourceID
-- 		,'' AS DeviceSourceID
-- 		, sttLocID AS LocationKey
-- 		, sttTransDate AS TransDate
-- 		, CONVERT(DATETIME2(3), CONVERT(VARCHAR(10), sttTransDate, 23) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(sttTransTime AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')) AS TransTime
-- 		, sttEnter AS GuestEntry
-- 		, sttExit AS GuestExit
-- 		, CASE WHEN sttCode = 1 THEN 'A' ELSE 'I' END AS DataIndicator
-- 		, sttLoadDate AS LoadDate
-- 		, ROW_NUMBER() OVER(PARTITION BY sttLocID, sttTransDate, sttTransTime ORDER BY sttLocID, sttTransDate, sttTransTime DESC) AS RowNum
-- 	FROM [$(Source_Data)].[Retail_Shoppertrack].[EnterpriseAPITrafficCount]
-- 	WHERE sttTransDate BETWEEN CAST(GETDATE()-120 AS DATE) AND CAST(GETDATE()-2 AS DATE)
-- )

/*History Traffic Load
, CTE_TrafficHistory AS
(
	SELECT
		'' AS DataSource
		, ISNULL(CAST(sttShopperTrakOrgID AS VARCHAR(20)), '') AS DeviceSourceID
		, sttLocID AS LocationKey
		, CONVERT(DATE, CAST(sttTransDate AS VARCHAR(8)), 112) AS TransDate
		, CONVERT(DATETIME2(3), CONVERT(VARCHAR(10), sttTransDate, 23) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(sttTransTime AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')) AS TransTime
		, sttEnter AS GuestEntry
		, sttExit AS GuestExit
		, sttDataTypeIndicator AS DataIndicator
		, sttLoadDate AS LoadDate
		, ROW_NUMBER() OVER(PARTITION BY sttShopperTrakOrgID, sttTransDate, sttTransTime ORDER BY sttShopperTrakOrgID, sttTransDate, sttTransTime, sttLoadDate DESC) AS RowNum
	FROM [$(Source_Data)].[Retail_Shoppertrack].[TrafficCount_History] WHERE sttTransDate < '20250721'
)

SELECT
	DataSource
	, DeviceSourceID
	, LocationKey
	, TransDate
	, TransTime
	, GuestEntry
	, GuestExit
	, DataIndicator
	, LoadDate
FROM CTE_TrafficHistory
WHERE RowNum = 1

UNION ALL
--*/

-- SELECT
-- 	DataSource
-- 	, DeviceSourceID
-- 	, LocationKey
-- 	, TransDate
-- 	, TransTime
-- 	, GuestEntry
-- 	, GuestExit
-- 	, DataIndicator
-- 	, LoadDate
-- FROM CTE_Traffic
-- WHERE RowNum = 1

-- UNION ALL

SELECT 
DataSource,
DeviceSourceID,
LocationKey,
TransDate,
TransTime,
GuestEntry,
GuestExit,
DataIndicator,
LoadDate
from 
(
SELECT
	dataSource AS DataSource
    --sttShopperTrakOrgID AS DeviceSourceID
	,'' AS DeviceSourceID
    , sttLocID AS LocationKey
    , CONVERT(DATE, CAST(sttTransDate AS VARCHAR(8))) AS TransDate
    , CONVERT(DATETIME2(3), CAST(sttTransDate AS VARCHAR(8)) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(sttTransTime AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')) AS TransTime
    , sttEnter AS GuestEntry
    , sttExit AS GuestExit
    , 'A' AS DataIndicator
    , sttLoadDate AS LoadDate
	, ROW_NUMBER() OVER( PARTITION BY sttLOCID, sttTransDate, sttTransTime ORDER BY sttTransDate, sttTransTime desc)  as RN
FROM [$(Source_Data)].[Retail_Shoppertrack].[RealTimeTrafficCount]
WHERE sttTransDate >= REPLACE(CAST(GETDATE()-2 AS DATE), '-','') 
AND sttTransDate < REPLACE(cast(getdate() as date), '-','')
) TBL
WHERE RN = 1