CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_OrangeHourly]
AS
BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_OrangeHourly';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'FactTraffic_Hourly';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);
	
	BEGIN TRY

		DECLARE @reportdate DATE = cast(cast((getdate() AT TIME ZONE 'UTC') AT TIME ZONE 'Central Standard Time' as datetime) as date)
		DECLARE @reportdate_f VARCHAR(10) = replace(cast(cast((getdate() AT TIME ZONE 'UTC') AT TIME ZONE 'Central Standard Time' as datetime) as date), '-','')

		UPDATE [Retail_DW_Core].[ReportRunControl]  SET ReportControl = 0 WHERE ReportName = 'HourlyReport';
		update [Retail_DW_Core].[ReportRunControl] 
		set MaxSalesTime = (select max(CAST(transactionDate AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATETIME2))
		 from [$(Source_Data)].[MasterData_Retail].[StorisHourlySalesData]) WHERE ReportName = 'HourlyReport';
		 
		-- Traffic
		
		DROP TABLE IF EXISTS [Retail_DW_Core].[StoreTraffic_Hourly_Holding];
		CREATE TABLE [Retail_DW_Core].[StoreTraffic_Hourly_Holding]
		(
			[LocationKey] [varchar](20) NOT NULL,
			[TransDate] [date] NOT NULL,
			[TransTime] [datetime2](3) NOT NULL,
			[GuestEntry] [int] NULL
		);
		INSERT INTO [Retail_DW_Core].[StoreTraffic_Hourly_Holding] 
		SELECT 
			LocationKey,
			TransDate,
			TransTime,
			GuestEntry
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
				, ROW_NUMBER() OVER( PARTITION BY sttLOCID, sttTransTime ORDER BY sttTransTime desc)  as RN
			FROM [$(Source_Data)].[Retail_Shoppertrack].[RealTimeTrafficCount]
			WHERE sttTransDate = @reportdate_f
			) TBL
			WHERE RN = 1
		
		DROP TABLE IF EXISTS [Retail_DW_Core].[FactTraffic_Hourly]
			
		CREATE TABLE [Retail_DW_Core].[FactTraffic_Hourly]
		(
			[StoreID] [int] NULL,
			[TransDate] [date]  NULL,
			[TransDay] [int] NULL,
			[TransHour] [decimal](18,2) NULL,
			[TransHourMinute] [decimal](18,2) NULL,
			[IsOpen] [int] NOT NULL,
			[IsOverride] [int] NOT NULL,
			[TrafficCount] [decimal](19,4) NULL
		)
		
		INSERT INTO [Retail_DW_Core].[FactTraffic_Hourly]
		(StoreID
		,TransDate
		,TransDay
		,TransHour
		,TransHourMinute
		,IsOpen
		,IsOverride
		,TrafficCount
		)
			
		SELECT 
			loc.StoreID
			, st.TransDate
			, DAY(st.TransDate) AS TransDay
			, CAST(DATEPART(HOUR, st.TransTime) AS DECIMAL(18,2)) AS TransHour
			, CAST(DATEPART(HOUR, st.TransTime) + (CAST(DATEPART(MINUTE, st.TransTime) AS DECIMAL(5,2)) / 60) AS DECIMAL(18,2)) AS TransHourMinute
			, 0 AS IsOpen
			, 0 AS IsOverride
			, CAST(CAST(st.GuestEntry AS DECIMAL(19,4)) / sts.DivideBy  AS DECIMAL(19,4)) AS TrafficCount
		FROM [Retail_DW_Core].[DimStoreLocation] loc 
			LEFT JOIN [Retail_DW_Core].[DimRollUps] roll ON loc.StoreID = roll.StoreID and roll.[RollUp] = 'ALSTR'
			LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[ShopperTrakStores] sts ON cast(sts.StoreID as INT)  = loc.StoreID
			LEFT JOIN [Retail_DW_Core].[StoreTraffic_Hourly_Holding] st ON st.locationkey = sts.APIStoreID
			
		
		--IsOpen

		UPDATE st
		SET st.IsOpen = 1
		FROM [Retail_DW_Core].[FactTraffic_Hourly] st
		INNER JOIN [$(Source_Data)].[Retail_External].[StoreDailyOpenHours] sdoh
		ON st.StoreID = sdoh.StoreID
		AND CAST(st.TransDate AS DATE) = CAST(sdoh.TransDate AS DATE)
		AND st.TransHourMinute >= sdoh.OpenTime
		AND st.TransHourMinute < sdoh.CloseTime
		-- AND cast(sdoh.TransDate as date) = @reportdate
		
		DELETE st
		FROM [Retail_DW_Core].[FactTraffic_Hourly] st
		INNER JOIN [$(Source_Data)].[Retail_Miniapps].[TrafficRequests] tr
		ON st.StoreID = tr.LocationID
		AND st.TransDate = CAST(tr.TransDate AS DATE)
		AND cast(st.TransHour AS INT) = CAST(tr.TransHour AS INT);
		
		INSERT INTO [Retail_DW_Core].[FactTraffic_Hourly]
		(StoreID
		,TransDate
		,TransDay
		,TransHour
		,TransHourMinute
		,IsOpen
		,IsOverride
		,TrafficCount
		)
		SELECT
			tr.LocationID AS StoreID
			, CAST(tr.TransDate AS DATE) AS TransDate
			, DAY(tr.TransDate) AS TransDay
			, tr.TransHour AS TransHour
			, tr.TransHour AS TransHourMinute
			, 1 AS IsOpen
			, 1 AS IsOverride
			, tr.ChangeCount AS TrafficCount
			
		FROM [$(Source_Data)].[Retail_Miniapps].[TrafficRequests] tr
		WHERE 
		CAST(tr.TransDate AS DATE) =  @reportdate;
		
		
		
drop table if EXISTS Retail_DW_Core.OrangeHourly

drop table if EXISTS Retail_DW_Core.SOCloseHour

SELECT
CONCAT(CONVERT(VARCHAR(8), TransDate, 112), StoreID, CustomerID) AS SuperOrderID
, CustomerID
, StoreID
, CONVERT(VARCHAR(8), TransDate, 112) AS OrderDateKey
, SalespersonID
, CONVERT(VARCHAR(8), TransDate, 112) AS TransDateKey
, OrderID
, SUM(COALESCE(NetSales, 0)) AS Sales
, SIGN(SUM(COALESCE(NetSales, 0))) AS SPClose
, CAST(0.0 AS DECIMAL(18, 2)) AS SUClose
, CAST(0.0 AS DECIMAL(18, 2)) AS SOClose

INTO Retail_DW_Core.SOCloseHour
FROM [$(Source_Data)].[Retail_Corporate].[BtaData]
WHERE -- CONVERT(VARCHAR(8), OrderDate, 112) <= q.TransDateKey AND
      Source = 'W'  AND TransDate = @reportdate
GROUP BY CONCAT(CONVERT(VARCHAR(8), TransDate, 112), StoreID, CustomerID),
         CustomerID,
         StoreID,
         CONVERT(VARCHAR(8), TransDate, 112),
         SalespersonID,
         CONVERT(VARCHAR(8), TransDate, 112),
         OrderID;
		 

UPDATE ccv
SET ccv.SOClose = CASE WHEN cls.SOTot = 0 THEN 0 ELSE ccv.SPClose / ABS(cls.SOTot)END
FROM  Retail_DW_Core.SOCloseHour AS ccv
INNER JOIN (
    SELECT ccv2.SuperOrderID,
            ccv2.OrderID,
           ccv2.SalesPersonID,
           SUM(ccv2.SPClose) OVER (PARTITION BY ccv2.SuperOrderID) AS SUTot,
			SUM(ccv2.SPClose) OVER (PARTITION BY ccv2.OrderID) AS SOTot
    FROM  Retail_DW_Core.SOCloseHour ccv2
) cls ON cls.SuperOrderID = ccv.SuperOrderID 
     AND cls.SalesPersonID = ccv.SalesPersonID
     AND cls.OrderID = ccv.OrderID;	       

;WITH 

SalesBudget AS
(select StoreID
,SUM(WrittenSales*PrimaryCategory) as wrtslsBud
, SUM(CASE WHEN CategoryID = 'DLVY' THEN writtensales END)  AS wrtslsotherBud
-- , SUM(DeliveredSales) as wrtslsotherBud
, SUM(WrittenGM) as wrtcogsBud
-- ,0 as wrtsoBud
 FROM Retail_DW_Core.FactSalesBudget 
 WHERE TransDate = @reportdate GROUP BY StoreID
 )
 
 ,TrafficBudget
 AS
 (select distinct StoreID, TUGoal, RUGoal, CloseGoal, CloseGoal as wrtsoBud
 from Retail_DW_Core.FactTrafficandCloseBudget
 where TransDate = @reportdate)


, CTE_Sales AS
(
select storeId as StoreID, 
count(distinct orderId) socount, 
sum(netSales+protection_plan_sales_price-protection_plan_return_price) as sls,
 1 as sls_other
, sum(netCost) as wrtcogs
, sum(protection_plan_sales_cost) as protection_plan_sales_cost
, sum(protection_plan_sales_price) as wrtsls_Fpp
from [$(Source_Data)].[MasterData_Retail].[StorisHourlySalesData] a 
where cast(CAST(transactionDate AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATETIME2) as date) = @reportdate and writtenFlag = 1
-- where cast(transactionDate as date) = @reportdate and writtenFlag = 1
group by storeId
--order by storeid
)



-- For OrderCount
,OrderCount as 
(
select StoreID, sum(isnull(SOClose,0)) as socount 
from Retail_DW_Core.SOCloseHour
where TransDateKey = @reportdate_f
group by StoreID
)


/*
,OrderCount as 
(
select locationid as storeid, sum(isnull(soclose,0)) as socount 
from [$(Retail_Warehouse)].[Retail_Sales_Enh].[SalesOrderCloses]
where transdatekey = @reportdate_f
group by locationid
-- order by locationid
)
*/

-- Bedding
,SalesBedding
AS
(
select storeId as StoreID, 
count(distinct orderId) socount
, sum(case when CategoryID = 'BEDDI' then netSales end) as wrtsls_Bedding
from [$(Source_Data)].[MasterData_Retail].[StorisHourlySalesData] a 
left join [Retail_DW_Core].[DimProduct] b on a.productId COLLATE Latin1_General_100_CI_AS_KS_WS_SC_UTF8 = b.SKU
where cast(CAST(transactionDate AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' AS DATETIME2) as date) = @reportdate and writtenFlag = 1
-- where cast(transactionDate as date) = @reportdate and writtenFlag = 1
group by storeId
--order by storeid
)

-- Recorded Guests
, RecordedGuest AS 
(select StoreID, SUM(isCountedAsUP) as Recorded_Guest
FROM [$(Source_Data)].[MasterData_Retail].[SalespersonUPBoardHistoryDSG]
where RecordedUpDate = @reportdate
group by StoreID

union 

select b.StoreID, SUM(IsUp) as Recorded_Guest 
from [$(Source_Data)].[MasterData_Retail].[SalespersonUPBoardHistoryAGR] a
left join (
SELECT 
			ss.StoreID AS ScoreboardStoreID
			, CASE WHEN ss.StoreNumber = 16090 THEN 421
				WHEN ss.StoreNumber = 16198 THEN 622
				WHEN ss.StoreNumber = 16736 THEN 720
				WHEN ss.StoreNumber = 16680 THEN 719
				WHEN ss.StoreNumber = 7521 THEN 342
				WHEN ss.StoreNumber = 99999 THEN 999
				ELSE st.RetailSystemNumber END AS StoreID
			, ss.StoreName
		FROM [$(Source_Data)].[MasterData_Retail].[ScoreboardStore] ss
		LEFT JOIN [$(Source_Data)].[MasterData_Retail].[SiteMasterLocations] st
		ON (LEN(ss.StoreNumber) = 3 AND LTRIM(ss.StoreNumber, '0') = st.RetailSystemNumber)
		OR (LEN(ss.StoreNumber) <> 3 AND ss.StoreNumber = st.financialUnitNumber)
) b on a.StoreID = b.ScoreboardStoreID
where cast(SalespersonUPBoardHistoryLocalTimeStatusStart as DATE) = @reportdate
group by b.StoreID
-- order by b.StoreID
)
-- App count
, StoreAppCount AS 
(-- App
select StoreID, count(distinct CustomerID) as FinApp  from [$(Source_Data)].[MasterData_Retail].[CreditReview]
where cast(QueuedDateTime as date) = @reportdate
group by storeid 
-- order by storeid
)

-- Delivery
,CTE_SiteData AS (
    SELECT 
		CAST(RetailSystemNumber AS INT) AS RetailSystemNumber
		, ROW_NUMBER() OVER(PARTITION BY RetailSystemNumber ORDER BY RetailSystemNumber) AS RN
    FROM [$(Source_Data)].[MasterData_Retail].[SiteMasterLocations]
	WHERE RetailSystemNumber IS NOT NULL
	AND CompanyCode IN ('DSG', 'AGR')
)

,CTE_TransCode AS (
    SELECT 
		Description
		, TransCodeID
		, CASE WHEN TransCodeID <= 20 then 1 ELSE -1 END AS TransCodeMultiplier
		, CASE WHEN TransCodeID IN (0, 1, 2, 7, 30, 31, 37, 20, 50) THEN 1 Else 0 END as TransCodeInvoiceFlag
    FROM [$(Source_Data)].[Retail_Corporate].[TransCode]
)

,CTE_OrderHeader AS (
	SELECT
		o.DateCreated
		, CASE    
			WHEN o.TransCodeID = '0' THEN 'Sale'
			WHEN o.TransCodeID = '7' THEN 'Exchange'
			WHEN o.TransCodeID LIKE '3%' AND LEN(o.TransCodeID) = 2 THEN 'Return'
			WHEN o.TransCodeID = '6' THEN 'Quote'
			WHEN o.TransCodeID LIKE '1%' AND LEN(o.TransCodeID) = 2 THEN 'Service'
			WHEN o.TransCodeID LIKE '6%' AND LEN(o.TransCodeID) = 2 AND o.TransCodeID <> '6' THEN 'Transfer'
			WHEN o.TransCodeID = '3' THEN 'Layaway'
			ELSE ''
			END AS OrderType
		, sm.RetailSystemNumber AS StoreID
		, o.OrderDate
		, o.TransactionSaveTime
		, o.TransactionStartTime
		, o.DlvyChrg AS DeliveryCharge
	FROM [$(Source_Data)].[Retail_Corporate].[Orders] o
	LEFT JOIN CTE_TransCode tr ON tr.TransCodeID = o.TransCodeID
	INNER JOIN CTE_SiteData sm ON sm.RetailSystemNumber = CAST(o.OrderBookedStoreID AS INT)

	WHERE 	cast(TransactionStartTime as date) = @reportdate
	AND ISNUMERIC(o.OrderBookedStoreID) = 1
AND sm.RN = 1
	--AND o.OrderID NOT LIKE '%[A-Z][A-Z][0-9]%'
	AND NOT EXISTS
	(
		SELECT 1
		FROM [$(Source_Data)].[Retail_Corporate].[Invoice] inv
		WHERE inv.OrderID = o.OrderID
	)
  
union all
select 
i.DateCreated
, CASE    
			WHEN i.TransCodeID = '0' THEN 'Sale'
			WHEN i.TransCodeID = '7' THEN 'Exchange'
			WHEN i.TransCodeID LIKE '3%' AND LEN(i.TransCodeID) = 2 THEN 'Return'
			WHEN i.TransCodeID = '6' THEN 'Quote'
			WHEN i.TransCodeID LIKE '1%' AND LEN(i.TransCodeID) = 2 THEN 'Service'
			WHEN i.TransCodeID LIKE '6%' AND LEN(i.TransCodeID) = 2 AND i.TransCodeID <> '6' THEN 'Transfer'
			WHEN i.TransCodeID = '3' THEN 'Layaway'
			ELSE ''
			END AS OrderType

,i.OrderBookedStoreID
, i.OrderDate
, i.TransactionSaveTime
, i.TransactionStartTime
, CAST(ISNULL(i.DlvyChrg, 0) AS DECIMAL(19,4)) * ISNULL(tr.TransCodeMultiplier, 1) AS DeliveryCharge
	FROM [$(Source_Data)].[Retail_Corporate].[Invoice] i
	LEFT JOIN CTE_TransCode tr
	ON tr.TransCodeID = i.TransCodeID
	INNER JOIN CTE_SiteData sm
	ON sm.RetailSystemNumber = CAST(i.OrderBookedStoreID AS INT)
	WHERE cast(TransactionStartTime as date) = @reportdate
	AND ISNUMERIC(i.OrderBookedStoreID) = 1 
	AND sm.RN = 1
	AND i.OrderID NOT IN ('919950482*ˆ', '919951412*^', '919951412*ž', '919951412*Š', '919950482*Š', '919951412*Œ', '919950482*Œ')

    )

, dlvy AS
( SELECT StoreID, sum(isnull(DeliveryCharge,0)) as sls_other FROM CTE_OrderHeader oh   where ordertype = 'Sale' group by storeid )


select loc.LocationName as storelocation, loc.StoreID as locationkey, [RollUp] as Division, case when (LocationName LIKE '%Morrow%' OR LocationName like '%Outlet%') then 'Outlet' else 'Homestore' end as HSType
, a.sls,cnt.socount, dv.sls_other, a.wrtsls_Fpp, bed.wrtsls_Bedding, a.wrtcogs
, DerivedUps, r.Recorded_Guest, b.wrtslsBud, b.wrtslsotherBud, c.wrtsoBud, b.wrtcogsBud, c.TUGoal as DerivedUpsBud, CloseGoal, CloseGoal*TUGoal as SaleCountGoal,
CASE WHEN CompLocation = 1 THEN 'Yes' Else 'No' END as CompLocation, FinApp
into  Retail_DW_Core.OrangeHourly

from Retail_DW_Core.DimStoreLocation loc
left join Retail_DW_Core.DimRollUps roll on loc.StoreID = roll.StoreID and 
	(RollUpFilter in ('Division', 'Region') or [RollUp] = 'ALSTR')
left join CTE_Sales a on loc.StoreID = a.StoreID
left join OrderCount cnt on loc.StoreID = cnt.storeid
left join dlvy dv on loc.StoreID = dv.storeid
left join SalesBedding bed on loc.StoreID = bed.StoreID
left join
	(select StoreID, sum(TrafficCount * IsOpen) as DerivedUps from
		[Retail_DW_Core].[FactTraffic_Hourly] group by StoreID) t on loc.StoreID = t.StoreID
left join StoreAppCount app on loc.StoreID = app.StoreID
left join RecordedGuest r on loc.StoreID = r.StoreID
left join SalesBudget b on loc.StoreID = b.StoreID
left join TrafficBudget c on loc.StoreID = c.storeID


drop table if EXISTS Retail_DW_Core.SOCloseHour;

UPDATE [Retail_DW_Core].[ReportRunControl]  SET ReportControl = 1 WHERE ReportName = 'HourlyReport'


EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable;
	
	END TRY

	BEGIN CATCH
        
		DECLARE
			@ErrorMessage  VARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState    INT;

		SET @ErrorMessage = ERROR_MESSAGE();
		SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
		SET @ErrorState = ISNULL(ERROR_STATE(), 0);
		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, @ErrorMessage
		);

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	END CATCH


END