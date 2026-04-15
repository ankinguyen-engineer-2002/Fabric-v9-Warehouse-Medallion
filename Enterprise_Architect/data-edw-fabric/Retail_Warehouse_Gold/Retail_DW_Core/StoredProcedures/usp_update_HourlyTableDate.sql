CREATE   PROCEDURE [Retail_DW_Core].[usp_update_HourlyTableDate]
AS
BEGIN
insert into Retail_DW_Core.HourlyTableTime
select 1, max(CAST(getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2))  as currenttime, 
'masterdata_retail.storishourlysalesdata ' as tablename
-- max(CAST(servertime AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2)) as server
,max(CAST(transactionDate AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2)) as trans
from [$(Source_Data)].MasterData_Retail.StorisHourlySalesData

insert into Retail_DW_Core.HourlyTableTime
select 2, max(CAST(getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2))  as currenttime,
'Retail_Shoppertrack.RealTimeTrafficCount' as tablename,
cast(CONVERT(DATE, CAST(max(sttTransDate) AS VARCHAR(8))) as varchar) + ' '
        + cast( CONVERT(TIME,
        STUFF(
            STUFF(
                RIGHT('000000' + CAST(max(sttTransTime) AS VARCHAR(6)), 6),
                5, 0, ':'
            ),
            3, 0, ':'
        )
    )  as varchar)
    as newv
    FROM [$(Source_Data)].[Retail_Shoppertrack].[RealTimeTrafficCount]
where sttTransDate = 20260114


insert into Retail_DW_Core.HourlyTableTime
select 3, max(CAST(getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2))  as currenttime, 
'Retail_Corporate.BtaData' as tablename,
 greatest(max(DateChanged),max(DateCreated)) as lastupdatedtime
from [$(Source_Data)].[Retail_Corporate].[BtaData] ;

insert into Retail_DW_Core.HourlyTableTime
select 4, max(CAST(getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2))  as currenttime, 
'Retail_Corporate.Orders' as tablename,
 greatest(max(DateChanged),max(DateCreated)) as lastupdatedtime
from [$(Source_Data)].[Retail_Corporate].[Orders] ;

insert into Retail_DW_Core.HourlyTableTime
select 5, max(CAST(getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2))  as currenttime, 
'Retail_Corporate.Invoice' as tablename,
 greatest(max(DateChanged),max(DateCreated)) as lastupdatedtime
from [$(Source_Data)].[Retail_Corporate].[Invoice] ;


insert into Retail_DW_Core.HourlyTableTime
select 6, max(CAST(getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2))  as currenttime, 
'MasterData_Retail.CreditReview' as tablename,
 greatest(max(DateChanged),max(DateCreated)) as lastupdatedtime
from [$(Source_Data)].[MasterData_Retail].[CreditReview];

insert into Retail_DW_Core.HourlyTableTime
select 7, max(CAST(getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Central Standard Time' AS DATETIME2))  as currenttime,
'MasterData_Retail.SalespersonUPBoardHistoryAGR' as tablename,
 max(SalespersonUPBoardHistoryLocalTimeStatusStart) as lastupdatedtime
from [$(Source_Data)].[MasterData_Retail].[SalespersonUPBoardHistoryAGR] ;


-- select * from Retail_DW_Core.HourlyTableTime order by currenttime, recno
END