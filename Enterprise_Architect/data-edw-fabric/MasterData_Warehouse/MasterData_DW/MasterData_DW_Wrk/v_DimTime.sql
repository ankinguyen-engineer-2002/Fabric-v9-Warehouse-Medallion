CREATE VIEW [MasterData_DW_Wrk].[v_DimTime]
  AS 	SELECT	 [TimeKey]
			,CAST(REPLACE(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),108),':','') AS INT) AS [TimeID]
			,CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),108) AS [TimeOfDayMilitary]
			,CASE WHEN DATEPART(Hour, [Time_Stamp]) BETWEEN 1 AND 9 OR DATEPART(Hour, [Time_Stamp]) BETWEEN 13 and 21  
				  THEN LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 4) 
				  ELSE LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 5) END
			 + ':' + RIGHT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),108),2) + ' ' + RIGHT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) AS [TimeOfDayAMPM]
			,DATEPART(Hour, [Time_Stamp]) AS [HourOfDayMilitartyID]
			,CASE WHEN DATEPART(Hour, [Time_Stamp]) BETWEEN 1 AND 9 OR DATEPART(Hour, [Time_Stamp]) BETWEEN 13 and 21
			 THEN LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 1)
			 ELSE LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) END
			 + ' ' + RIGHT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) AS [HourOfDayAMPMID]
			,LEFT(CONVERT(VARCHAR(8), [T].[Time_Stamp], 108),2) + ':00:00' AS [HourOfDayMilitary]
			,CASE WHEN DATEPART(Hour, [Time_Stamp]) BETWEEN 1 AND 9 OR DATEPART(Hour, [Time_Stamp]) BETWEEN 13 and 21  
				  THEN LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) 
				  ELSE LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 3) END
			 + '00:00' + ' ' + RIGHT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) AS [HourOfDayAMPM]
			,CASE WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN  0 AND 14 THEN 1 
				  WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 15 AND 29 THEN 2 
				  WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 30 AND 44 THEN 3 
				  WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 45 AND 59 THEN 4 END AS [QuarterOfHourID]
			,LEFT(CONVERT(VARCHAR(8), [T].[Time_Stamp], 108),2) +
			 CASE WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN  0 AND 14 THEN ':00:00' 
				  WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 15 AND 29 THEN ':15:00' 
				  WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 30 AND 44 THEN ':30:00' 
				  WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 45 AND 59 THEN ':45:00' END AS [QuarterOfHourMilitary]
			,CASE WHEN DATEPART(Hour, [Time_Stamp]) BETWEEN 1 AND 9 OR DATEPART(Hour, [Time_Stamp]) BETWEEN 13 and 21  
				  THEN LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) 
				  ELSE LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 3) END
			 + CASE WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN  0 AND 14 THEN '00:00' 
					WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 15 AND 29 THEN '15:00' 
					WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 30 AND 44 THEN '30:00' 
					WHEN DATEPART(Minute, [Time_Stamp]) BETWEEN 45 AND 59 THEN '45:00' END + 
			  ' ' + RIGHT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) AS [QuarterofHourAMPM]
			,DATEPART(Minute, [Time_Stamp]) AS [MinuteOfHourID]
			,LEFT(CONVERT(VARCHAR(8), [T].[Time_Stamp], 108),5) + ':00' AS [MinuteOfDayMilitary]
			,CASE WHEN DATEPART(Hour, [Time_Stamp]) BETWEEN 1 AND 9 OR DATEPART(Hour, [Time_Stamp]) BETWEEN 13 and 21  
				  THEN LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 4) 
				  ELSE LEFT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 5) END
			 + ':00' + ' ' + RIGHT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) AS [MinuteOfDayAMPM]
			,DATEPART(Second, [Time_Stamp]) AS [SecondOfMinuteID]
			,RIGHT(CONVERT(varchar(15),CAST([Time_Stamp] AS TIME),100), 2) AS [AMPM]
			,CASE	WHEN DATEPART(Hour, [Time_Stamp]) =  0 THEN '12:00am - 12:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  1 THEN '1:00am - 1:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  2 THEN '2:00am - 2:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  3 THEN '3:00am - 3:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  4 THEN '4:00am - 4:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  5 THEN '5:00am - 5:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  6 THEN '6:00am - 6:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  7 THEN '7:00am - 7:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  8 THEN '8:00am - 8:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) =  9 THEN '9:00am - 9:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) = 10 THEN '10:00am - 10:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) = 11 THEN '11:00am - 11:59am'
					WHEN DATEPART(Hour, [Time_Stamp]) = 12 THEN '12:00pm - 12:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 13 THEN '1:00pm - 1:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 14 THEN '2:00pm - 2:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 15 THEN '3:00pm - 3:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 16 THEN '4:00pm - 4:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 17 THEN '5:00pm - 5:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 18 THEN '6:00pm - 6:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 19 THEN '7:00pm - 7:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 20 THEN '8:00pm - 8:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 21 THEN '9:00pm - 9:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 22 THEN '10:00pm - 10:59pm'
					WHEN DATEPART(Hour, [Time_Stamp]) = 23 THEN '11:00pm - 11:59pm'	END AS [HourOfDayAMPMRange]


	FROM (
		SELECT [Seconds] AS [TimeKey],
		DATEADD(Second, [Seconds], CAST(CAST(CAST(GETDATE()  AS DATE) AS DATETIME) AS TIME)) AS [Time_Stamp]
		FROM (
			SELECT TOP (86400) [Seconds] = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[DateKey])) - 1 
			FROM MasterData_DW.DimDate AS s1 CROSS JOIN MasterData_DW.DimDate AS s2) S ) T
		
