CREATE PROCEDURE [Retail_DW_Core].[usp_Refresh_SanityMaster]
AS
BEGIN

/*
CREATE TABLE Retail_DW_Core_Wrk.SanityData_Result
(
[ReportDate] DATE NOT NULL,
[Layer] Varchar(50) NOT NULL,
[Table] varchar(200) NOT NULL,
[MetricName] VARCHAR(100) NOT NULL,
[StoreID] INT NOT NULL,
[TransDate] DATE NOT NULL,
[SourceCount] decimal(16,2) NULL,
[DestinationCount] decimal(16,2) NULL,
[Difference] decimal(16,2) NULL,
[Result] VARCHAR(20) NULL
)

 select * from Retail_DW_Core_Wrk.SanityData_Result
 drop TABLE Retail_DW_Core_Wrk.SanityData_Result
*/

DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_SanityMaster';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'SanityData_Result';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

BEGIN TRY

DECLARE @Transdate date
set @Transdate='2026-01-26'

--TRAFFIC COUNT--

--BronzeCount
DROP TABLE IF EXISTS [Retail_DW_Core_Wrk].[StoreTraffic_Bronze_Holding];
		CREATE TABLE [Retail_DW_Core_Wrk].[StoreTraffic_Bronze_Holding]
		(
			[LocationKey] [varchar](20) NOT NULL,
			[TransDate] [date] NOT NULL,
			[TransTime] [datetime2](3) NOT NULL,
			[GuestEntry] [int] NULL
		);
		INSERT INTO [Retail_DW_Core_Wrk].[StoreTraffic_Bronze_Holding] 
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
			WHERE sttTransDate = FORMAT(@Transdate,'yyyyMMdd')
			) TBL
			WHERE RN = 1
		DROP TABLE IF EXISTS [Retail_DW_Core_Wrk].[FactTraffic_Bronze] 
		CREATE TABLE [Retail_DW_Core_Wrk].[FactTraffic_Bronze] 
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
		INSERT INTO [Retail_DW_Core_Wrk].[FactTraffic_Bronze]
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
			LEFT JOIN [Retail_DW_Core_Wrk].[StoreTraffic_Bronze_Holding]  st ON st.locationkey = sts.APIStoreID

		--IsOpen
 
		UPDATE st
		SET st.IsOpen = 1
		FROM [Retail_DW_Core_Wrk].[FactTraffic_Bronze] st
		INNER JOIN [$(Source_Data)].[Retail_External].[StoreDailyOpenHours] sdoh
		ON st.StoreID = sdoh.StoreID
		AND CAST(st.TransDate AS DATE) = CAST(sdoh.TransDate AS DATE)
		AND st.TransHourMinute >= sdoh.OpenTime
		AND st.TransHourMinute < sdoh.CloseTime
		-- AND cast(sdoh.TransDate as date) = @reportdate
		DELETE st
		FROM [Retail_DW_Core_Wrk].[FactTraffic_Bronze] st
		INNER JOIN [$(Source_Data)].[Retail_Miniapps].[TrafficRequests] tr
		ON st.StoreID = tr.LocationID
		AND st.TransDate = CAST(tr.TransDate AS DATE)
		AND cast(st.Transhour AS INT) = CAST(tr.TransHour AS INT);
		INSERT INTO [Retail_DW_Core_Wrk].[FactTraffic_Bronze]
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
		CAST(tr.TransDate AS DATE) =  @Transdate


        select StoreID, TransDate, sum(TrafficCount) as Traffic
        into  #BronzeData
        from [Retail_DW_Core_Wrk].[FactTraffic_Bronze] where TransDate is not NULL
        group by [StoreID],TransDate
        order by StoreID,TransDate

--SilverCount
select StoreID, TransDate, sum(TrafficCount*IsOpen) as Traffic
into #SilverData
from [$(Retail_Warehouse)].[Retail_Traffic].[StoreTraffic]
where TransDate=@Transdate
group by [StoreID], [TransDate]
order by [StoreID], [TransDate] DESC

--GoldCount
SELECT 
    StoreID as StoreID, 
    TransDate, 
    SUM(TrafficGuest) as Traffic
INTO #GoldData
FROM Retail_DW_Core.FactTraffic 
WHERE TransDate=@Transdate
GROUP BY StoreID, TransDate
ORDER BY StoreID, TransDate DESC


--Layer -> Silver
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer,TableName,MetricName,StoreID,TransDate,SourceCount, DestinationCount, Difference, Result)
select getdate(),'Silver','FactTraffic','Traffic',A.StoreID,A.TransDate, A.Traffic, B.Traffic, (B.Traffic - A.Traffic),
case when (B.Traffic - A.Traffic)=0 then 'True' else 'False' end
from #BronzeData A
left join #SilverData B
on A.StoreID = B.StoreID and A.TransDate = B.TransDate
order by A.StoreID, A.TransDate DESC

--Layer -> Gold
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer,TableName,MetricName,StoreID,TransDate,SourceCount, DestinationCount, Difference, Result)
select getdate(),'Gold','FactTraffic','Traffic',A.StoreID,A.TransDate, A.Traffic, B.Traffic, (B.Traffic - A.Traffic),
case when (B.Traffic - A.Traffic)=0 then 'True' else 'False' end
from #SilverData A
left join #GoldData B
on A.StoreID = B.StoreID and A.TransDate = B.TransDate
order by A.StoreID, A.TransDate DESC

--TRAFFIC -> STORES WITH NO TRAFFIC--
SELECT str.StoreID into #StoreNotPresent
FROM [Retail_DW_Core].[DimStoreLocation] str
left join Retail_DW_Core.DimRollUps ro on str.StoreID = ro.StoreID
where not exists (SELECT 1 from Retail_DW_Core.FactTraffic tra
WHERE str.StoreID = tra.StoreID and tra.TransDate=CAST(DATEADD(DAY, -2, GETDATE()) AS DATE)) and str.OperationalStatus = 'Active' AND str.LocationType = 'ST'
and [RollUp] = 'ALSTR'-- and locationname not like 'LIQUIDATION%'
and str.StoreID not in (469,499, 642,649,699)
order by str.StoreID

Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer,TableName,MetricName,StoreID,TransDate, Result, Description)
select getdate(),'Gold','FactTraffic','Traffic Missing Stores',StoreID,@Transdate,'False','Traffic Missing'
from #StoreNotPresent


--TRAFFIC -> Stores with 0 Traffic
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer,TableName,MetricName,StoreID,TransDate, Result, Description)
select getdate(),'Gold','FactTraffic','Zero Traffic',StoreID,@Transdate,'False','Zero Traffic in Gold'
from Retail_DW_Core.FactTraffic where TransDate=@Transdate
group by StoreID having SUM(TrafficGuest)=0


--TRAFFIC -> Override

DELETE FROM Retail_DW_Core_Wrk.SanityData_Result WHERE MetricName='Traffic Override'
--Silver Layer
select a.TransDate , a.StoreID, t as TrafficCount,  c as changedcount into #TrafficOverrideValidation_Silver from
(select TransDate , StoreID, sum(TrafficCount) as t from [$(Retail_Warehouse)].[Retail_Traffic].[StoreTraffic]
where TransDate  between '2026-01-01' and @Transdate and IsOverride = 1 group by TransDate , StoreID ) a
inner join
(select cast(TransDate as date) as TransDate, LocationID, sum(ChangeCount) as c from [$(Source_Data)].[Retail_Miniapps].[TrafficRequests]
where cast(TransDate as date)  between '2026-01-01' and @Transdate group by cast(TransDate as date) , LocationID) b
on a.StoreID = b.LocationID and a.TransDate = b.TransDate
where a.TransDate  between '2026-01-01' and @Transdate
order by a.TransDate , a.StoreID


Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer,TableName,MetricName,StoreID,TransDate,SourceCount, DestinationCount, Difference, Result, Description)
select getdate(),'Silver','FactTraffic','Traffic Override',StoreID,TransDate,changedcount,TrafficCount, (TrafficCount-changedcount),'False','Traffic Override Mismatch'
from #TrafficOverrideValidation_Silver where (TrafficCount - changedcount) <> 0


--Gold Layer
select a.TransDate , a.StoreID, t as TrafficCount,  c as changedcount into #TrafficOverrideValidation_Gold from
(select TransDate , StoreID, sum(TrafficGuest) as t from Retail_DW_Core.FactTraffic
where TransDate  between '2026-01-01' and @Transdate and IsOverride = 1 group by TransDate , StoreID ) a
inner join
(select cast(TransDate as date) as TransDate, LocationID, sum(ChangeCount) as c from [$(Source_Data)].[Retail_Miniapps].[TrafficRequests]
where cast(TransDate as date)  between '2026-01-01' and @Transdate group by cast(TransDate as date) , LocationID) b
on a.StoreID = b.LocationID and a.TransDate = b.TransDate
where a.TransDate  between '2026-01-01' and @Transdate
order by a.TransDate , a.StoreID

Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer,TableName,MetricName,StoreID,TransDate,SourceCount, DestinationCount, Difference, Result, Description)
select getdate(),'Gold','FactTraffic','Traffic Override',StoreID,TransDate,changedcount,TrafficCount, (TrafficCount-changedcount),'False','Traffic Override Mismatch'
from #TrafficOverrideValidation_Gold where (TrafficCount - changedcount) <> 0


------------------------------------------------------------------END of TRAFFIC Validation--------------------------------------------------------------------------------------

--WRITTEN--
--Gold Query
SELECT 
    sl.StoreID AS StoreID, 
    CAST(a.TransDateTime AS DATE) AS TransDate,
    SUM(Sales * PrimaryCategory) AS written
INTO #WrittenGold
FROM [Retail_DW_Core].[DimStoreLocation] sl 
LEFT JOIN [Retail_DW_Core].[FactSales] a 
    ON sl.LocationKey = a.LocationKey
LEFT JOIN Retail_DW_Core.DimProduct b 
    ON a.ProductKey = b.ProductKey
WHERE CAST(a.TransDateTime AS DATE) = @Transdate
    AND SalesType = 'W' 
GROUP BY sl.StoreID, CAST(a.TransDateTime AS DATE)
ORDER BY sl.StoreID, CAST(a.TransDateTime AS DATE)

--Result Table Insert and Update
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer, TableName,MetricName,StoreID,TransDate, DestinationCount,Result,Description)
select getdate(),'Gold','FactSales','WRITTEN',StoreID,TransDate,written,
case when written=0 then 'False' else NULL end,
case when written=0 then 'Written sales is zero' else '' end
from #WrittenGold 


--WRITTEN D--
--Gold Query
select sl.StoreID,
CAST(a.TransDateTime AS DATE) AS TransDate,
SUM(CASE WHEN SalesType = 'W' THEN ISNULL(a.Sales,0)*ISNULL(b.PrimaryCategory,0) ELSE 0 END)
 + SUM(CASE WHEN SalesType = 'W' AND b.CategoryID = 'DLVY' THEN ISNULL(a.Sales,0) ELSE 0 END) as [Written_D]
INTO #WrittenDGold
from [Retail_DW_Core].[FactSales] a
left join [Retail_DW_Core].[DimStoreLocation] sl on sl.LocationKey = a.LocationKey
left join Retail_DW_Core.DimProduct b on a.ProductKey = b.ProductKey
WHERE CAST(a.TransDateTime AS DATE) = @Transdate
and SalesType ='W'
group by sl.StoreID, CAST(a.TransDateTime AS DATE)
order by sl.StoreID, CAST(a.TransDateTime AS DATE)

--Result Table Insert and Update
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer, TableName,MetricName,StoreID,TransDate, DestinationCount,Result,Description)
select getdate(),'Gold','FactSales','WRITTEN D',StoreID,TransDate,Written_D,
case when Written_D=0 then 'False' else NULL end,
case when Written_D=0 then 'Written D is zero' else '' end
from #WrittenDGold 


--Delivered--
--Gold Query
select sl.StoreID,
CAST(a.TransDateTime AS DATE) AS TransDate,
SUM(CASE WHEN SalesType = 'D' THEN ISNULL(a.Sales,0)*ISNULL(b.PrimaryCategory,0) ELSE 0 END) AS [Delivered]
INTO #DeliveredGold
from [Retail_DW_Core].[FactSales] a
left join [Retail_DW_Core].[DimStoreLocation] sl on sl.LocationKey = a.LocationKey
left join Retail_DW_Core.DimProduct b on a.ProductKey = b.ProductKey
WHERE CAST(a.TransDateTime AS DATE) = @Transdate
group by sl.StoreID, CAST(a.TransDateTime AS DATE)
order by sl.StoreID, CAST(a.TransDateTime AS DATE)

--Result Table Insert and Update
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer, TableName,MetricName,StoreID,TransDate, DestinationCount,Result,Description)
select getdate(),'Gold','FactSales','Delivered',StoreID,TransDate,Delivered,
case when Delivered=0 then 'False' else NULL end,
case when Delivered=0 then 'Delivered is zero' else '' end
from #DeliveredGold

--Written GM--
--Gold Query
select sl.StoreID,
CAST(a.TransDateTime AS DATE) AS TransDate,
SUM(CASE WHEN SalesType = 'W' THEN (ISNULL(a.Sales,0) - ISNULL(a.Cost,0))*ISNULL(b.PrimaryCategory,0) ELSE 0 END) AS [Written_GM]
INTO #WrittenGMGold
from [Retail_DW_Core].[FactSales] a
left join [Retail_DW_Core].[DimStoreLocation] sl on sl.LocationKey = a.LocationKey
left join Retail_DW_Core.DimProduct b on a.ProductKey = b.ProductKey
WHERE CAST(a.TransDateTime AS DATE) = @Transdate
group by sl.StoreID, CAST(a.TransDateTime AS DATE)
order by sl.StoreID, CAST(a.TransDateTime AS DATE)

--Result Table Insert and Update
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer, TableName,MetricName,StoreID,TransDate, DestinationCount,Result,Description)
select getdate(),'Gold','FactSales','Written GM',StoreID,TransDate,Written_GM,
case when Written_GM=0 then 'False' else NULL end,
case when Written_GM=0 then 'Written GM is zero' else '' end
from #WrittenGMGold


--Delivered GM--
--Gold Query
select sl.StoreID,
CAST(a.TransDateTime AS DATE) AS TransDate,
SUM(CASE WHEN SalesType = 'D' THEN (ISNULL(a.Sales,0) - ISNULL(a.Cost,0))*ISNULL(b.PrimaryCategory,0) ELSE 0 END) AS [Delivered_GM]
INTO #DeliveredGMGold
from [Retail_DW_Core].[FactSales] a
left join [Retail_DW_Core].[DimStoreLocation] sl on sl.LocationKey = a.LocationKey
left join Retail_DW_Core.DimProduct b on a.ProductKey = b.ProductKey
WHERE CAST(a.TransDateTime AS DATE) = @Transdate
group by sl.StoreID, CAST(a.TransDateTime AS DATE)
order by sl.StoreID, CAST(a.TransDateTime AS DATE)

--Result Table Insert and Update
Insert into Retail_DW_Core_Wrk.SanityData_Result(ReportDate,Layer, TableName,MetricName,StoreID,TransDate, DestinationCount,Result,Description)
select getdate(),'Gold','FactSales','Delivered GM',StoreID,TransDate,Delivered_GM,
case when Delivered_GM=0 then 'False' else NULL end,
case when Delivered_GM=0 then 'Delivered GM is zero' else '' end
from #DeliveredGMGold



--select * from  Retail_DW_Core_Wrk.SanityData_Result where transdate='2026-01-21'
--where MetricName='WRITTEN_D' order by rundate desc-- where Result='Fail' order by StoreID


----------------------------------RSA VALIDATIONS--------------------------------------------------

DELETE FROM Retail_DW_Core_Wrk.RSA_SanityData_Result
--To check salesperson name  available or not in gold/silver/bronze
 
-- Step 1: Identify NULL SalesPersonName records in Gold layer
;WITH Gold AS (
    SELECT
        SalesPersonKey,
        SalesPersonID,
        SalesPersonName
    FROM [Retail_DW_Core].[DimSalesPerson]
    WHERE SalesPersonName IS NULL
),
 
-- Step 2: Check Silver layer for matching records
Silver AS (
    SELECT
        g.SalesPersonKey,
        g.SalesPersonID,
        g.SalesPersonName AS GoldName,
        s.SalesPersonName AS SilverName
    FROM Gold g
    LEFT JOIN [$(Retail_Warehouse)].[MasterData_Retail_Ent].[SalesPerson] s
        ON g.SalesPersonID = s.SalesPersonID
),
 
-- Step 3: Check Bronze layer (Miniapps) for matching records
BronzeMiniapps AS (
    SELECT
        sc.SalesPersonKey,
        sc.SalesPersonID,
        sc.GoldName,
        sc.SilverName,
        m.NAME AS BronzeMiniappsName,
        m.active_status AS MiniappsActiveStatus
    FROM Silver sc
    LEFT JOIN [$(Source_Data)].[Retail_Miniapps].[Salesman] m
        ON sc.SalesPersonID = m.ID
),

-- Step 4: Check Bronze layer (Corporate) for matching records
BronzeCorporate AS (
    SELECT
        bm.SalesPersonKey,
        bm.SalesPersonID,
        bm.GoldName,
        bm.SilverName,
        bm.BronzeMiniappsName,
        bm.MiniappsActiveStatus,
        c.Name AS BronzeCorporateName
    FROM BronzeMiniapps bm
    LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Salesperson] c
        ON bm.SalesPersonID = c.SalespersonID
)
 
-- Final Output: Anomaly Detection Results
SELECT
    SalesPersonKey,
    SalesPersonID,
    GoldName,
    SilverName,
    BronzeMiniappsName,
    MiniappsActiveStatus,
    BronzeCorporateName into #RSAFinal_Name
FROM BronzeCorporate
ORDER BY SalesPersonID;

--Rsult Insertion
Insert into Retail_DW_Core_Wrk.RSA_SanityData_Result(ReportDate, MetricName, SalesPersonKey, SalesPersonID, BronzeValue, SilverValue, GoldValue)
select getdate(), 'RSA - SalesPerson Name', SalesPersonKey, SalesPersonID,
case when BronzeMiniappsName is NULL then BronzeCorporateName
else BronzeMiniappsName end, SilverName, GoldName
from #RSAFinal_Name

-- Update
update Retail_DW_Core_Wrk.RSA_SanityData_Result set [Result] =
CASE
WHEN BronzeValue = SilverValue AND SilverValue = GoldValue THEN 'True'
WHEN GoldValue is NULL and (SilverValue is not null or BronzeValue is not null) THEN 'False'
WHEN BronzeValue <> GoldValue or SilverValue <> GoldValue THEN 'False'
ELSE 'False'
END,
[Priority] =
CASE WHEN
GoldValue is NULL and (BronzeValue is not NULL)  THEN 1
WHEN GoldValue is NULL and (BronzeValue is NULL)  THEN 3
WHEN BronzeValue <> GoldValue or SilverValue <> GoldValue THEN 2
END,
[Description] = 'Data Mismatch'
WHERE MetricName = 'RSA - SalesPerson Name'


--To check  Employeenumber available or not in gold/silver/bronze--

-- Step 1: Identify NULL EmployeeNumber records in Gold layer
;WITH Gold AS (
    SELECT
        SalesPersonKey,
        SalesPersonID,
        SalesPersonName,
        EmployeeNumber,
        PeopleID
    FROM [Retail_DW_Core].[DimSalesPerson]
    WHERE employeenumber IS NULL
),
 
-- Step 2: Check Silver layer for matching records
Silver AS (
    SELECT
        g.SalesPersonKey,
        g.SalesPersonID,
        g.PeopleID,
        g.SalesPersonName AS GoldName,
        g.EmployeeNumber AS GoldEmployeeNumber,
        s.SalesPersonName AS SilverName,
        s.EmployeeNumber AS SilverEmployeeNumber
    FROM Gold g
    LEFT JOIN [$(Retail_Warehouse)].[MasterData_Retail_Ent].[SalesPerson] s
        ON g.SalesPersonID = s.SalesPersonID
),
 
-- Step 3: Check Bronze layer (Staff) for matching records
BronzeStaff AS (
    SELECT
        sc.SalesPersonKey,
        sc.SalesPersonID,
        sc.PeopleID,
        sc.GoldName,
        sc.GoldEmployeeNumber,
        sc.SilverName,
        sc.SilverEmployeeNumber,
        st.Name AS BronzeStaffName,
        st.EmployeeNbr AS BronzeStaffEmployeeNumber
    FROM Silver sc
    LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Staff] st
        ON sc.SalesPersonID = st.SalespersonID
)
 
-- Final Output: Anomaly Detection Results
SELECT
    SalesPersonKey,
    SalesPersonID,
    PeopleID,
    GoldName,
    GoldEmployeeNumber,
    SilverName,
    SilverEmployeeNumber,
    BronzeStaffName,
    BronzeStaffEmployeeNumber INTO #RSAFinal_EmployeeNumber
FROM BronzeStaff
WHERE BronzeStaffEmployeeNumber IS NOT NULL
ORDER BY SalesPersonID;

-- Result Insertion
INSERT INTO Retail_DW_Core_Wrk.RSA_SanityData_Result(ReportDate, MetricName, SalesPersonKey, SalesPersonID, BronzeValue, SilverValue, GoldValue)
SELECT 
    GETDATE(), 
    'RSA - EmployeeNumber', 
    SalesPersonKey, 
    SalesPersonID,
    BronzeStaffEmployeeNumber,
    SilverEmployeeNumber,
    GoldEmployeeNumber
FROM #RSAFinal_EmployeeNumber;

-- Update
UPDATE Retail_DW_Core_Wrk.RSA_SanityData_Result 
SET [Result] =
    CASE
        WHEN BronzeValue = SilverValue AND SilverValue = GoldValue THEN 'True'
        WHEN GoldValue IS NULL AND (SilverValue IS NOT NULL OR BronzeValue IS NOT NULL) THEN 'False'
        WHEN BronzeValue <> GoldValue OR SilverValue <> GoldValue THEN 'False'
        ELSE 'False'
    END,
    [Priority] =
    CASE 
        WHEN GoldValue IS NULL AND (BronzeValue IS NOT NULL) THEN 1
        WHEN GoldValue IS NULL AND (BronzeValue IS NULL) THEN 3
        WHEN BronzeValue <> GoldValue OR SilverValue <> GoldValue THEN 2
    END,
    [Description] = 'Data Mismatch'
WHERE MetricName = 'RSA - EmployeeNumber';


		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);

		--- Update last modified in Table Dictionary 
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable

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