CREATE VIEW [CustomerOrders_AFI_Wrk].[v_RouteTimeFenceControl]
AS
SELECT Dfcntrl   AS ControlKey ,
       Dfwhse    AS Warehouse ,
       Dfvalue1  AS Value1    ,    
       Dfvalue2  AS Value2  ,  
       CASE WHEN CAST([Dfadddt] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([Dfadddt] as INT) AS CHAR(8)) AS DATE) END AS [AddedDate],
       Dfaddtm   AS AddedTime ,    
       Dfaddus   AS AddedByUser,   
       CASE WHEN CAST([Dfchgdt] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([Dfchgdt] as INT) AS CHAR(8)) AS DATE) END AS [ChangeDate],
       Dfchgtm   AS ChangeTime ,   
       Dfchgus   AS ChangedByUser 

FROM	[$(Source_Data)].[Wholesale_Codis_AFI].[DESDFTF] 
