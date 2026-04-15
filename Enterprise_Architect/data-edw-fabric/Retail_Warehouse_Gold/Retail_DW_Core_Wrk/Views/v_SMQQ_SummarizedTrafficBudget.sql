-- Auto Generated (Do not modify) 8F3C04DE3C62EE0310448D1B0249D79061074CF93CDE0DBC7735BC0BCB28479A
/* 
09/10/2025 || Harshit S: Created View
*/
CREATE   VIEW [Retail_DW_Core_Wrk].[v_SMQQ_SummarizedTrafficBudget] AS

WITH DateCalculations AS (
    -- Get the maximum date from FactTraffic to calculate dynamic week numbers
    SELECT 
        MAX(TransDate) AS Max_TransDate
    FROM [Retail_DW_Core].[SMQQ_FactTraffic]
),

ParameterValues AS (
    -- Dynamic week number calculations based on DAX measures
    SELECT 
        -- Start Week (Act) = MAX(TransDate) - (7 * 12 weeks) = 84 days
        CAST(
            CONCAT(
                CAST(YEAR(DATEADD(DAY, -84, dc.Max_TransDate)) AS VARCHAR(4)),
                CASE 
                    WHEN DATEPART(WEEK, DATEADD(DAY, -84, dc.Max_TransDate)) < 10 
                    THEN '0' + CAST(DATEPART(WEEK, DATEADD(DAY, -84, dc.Max_TransDate)) AS VARCHAR(2))
                    ELSE CAST(DATEPART(WEEK, DATEADD(DAY, -84, dc.Max_TransDate)) AS VARCHAR(2))
                END
            ) AS INT
        ) AS Start_Week_Act,
        
        -- End Week (Act) = MAX(TransDate) - (7 * 1 week) = 7 days
        CAST(
            CONCAT(
                CAST(YEAR(DATEADD(DAY, -7, dc.Max_TransDate)) AS VARCHAR(4)),
                CASE 
                    WHEN DATEPART(WEEK, DATEADD(DAY, -7, dc.Max_TransDate)) < 10 
                    THEN '0' + CAST(DATEPART(WEEK, DATEADD(DAY, -7, dc.Max_TransDate)) AS VARCHAR(2))
                    ELSE CAST(DATEPART(WEEK, DATEADD(DAY, -7, dc.Max_TransDate)) AS VARCHAR(2))
                END
            ) AS INT
        ) AS End_Week_Act,
        
        -- WeekNum +1 = TODAY() + 7 days
        CAST(
            CONCAT(
                CAST(YEAR(DATEADD(DAY, 7, GETDATE())) AS VARCHAR(4)),
                CASE 
                    WHEN DATEPART(WEEK, DATEADD(DAY, 7, GETDATE())) < 10 
                    THEN '0' + CAST(DATEPART(WEEK, DATEADD(DAY, 7, GETDATE())) AS VARCHAR(2))
                    ELSE CAST(DATEPART(WEEK, DATEADD(DAY, 7, GETDATE())) AS VARCHAR(2))
                END
            ) AS INT
        ) AS WeekNum_Plus1,
        
        -- WeekNum +13 = TODAY() + 91 days (13 weeks)
        CAST(
            CONCAT(
                CAST(YEAR(DATEADD(DAY, 91, GETDATE())) AS VARCHAR(4)),
                CASE 
                    WHEN DATEPART(WEEK, DATEADD(DAY, 91, GETDATE())) < 10 
                    THEN '0' + CAST(DATEPART(WEEK, DATEADD(DAY, 91, GETDATE())) AS VARCHAR(2))
                    ELSE CAST(DATEPART(WEEK, DATEADD(DAY, 91, GETDATE())) AS VARCHAR(2))
                END
            ) AS INT
        ) AS WeekNum_Plus13
    FROM DateCalculations dc
),

-- Employee History aggregations for RSA calculations
-- DAX uses ALL('Employee History') which means it ignores row context and calculates across all records
-- Matching the exact DAX logic: FILTER(ALL('Employee History'), conditions...)
EmployeeRSAStats AS (
    SELECT 
        eh.LocationID,
        
        -- FT RSAs Active
        -- DAX: SUM('Employee History'[Is RSA]) WHERE EmpStatus = "A" AND EmpFTPT = "F"
        ISNULL(SUM(CASE 
            WHEN eh.EmpStatus = 'A' AND eh.EmpFTPT = 'F' 
            THEN eh.Is_RSA 
            ELSE 0 
        END), 0) AS FT_RSAs_Active,
        
        -- FT RSAs LOA
        -- DAX: SUM('Employee History'[Is RSA]) WHERE EmpStatus = "L" AND EmpFTPT = "F"
        ISNULL(SUM(CASE 
            WHEN eh.EmpStatus = 'L' AND eh.EmpFTPT = 'F' 
            THEN eh.Is_RSA 
            ELSE 0 
        END), 0) AS FT_RSAs_LOA,
        
        -- PT RSAs Active
        -- DAX: SUM('Employee History'[Is RSA]) WHERE EmpStatus = "A" AND EmpFTPT = "P"
        ISNULL(SUM(CASE 
            WHEN eh.EmpStatus = 'A' AND eh.EmpFTPT = 'P' 
            THEN eh.Is_RSA 
            ELSE 0 
        END), 0) AS PT_RSAs_Active,
        
        -- PT RSAs LOA
        -- DAX: SUM('Employee History'[Is RSA]) WHERE EmpStatus = "L" AND EmpFTPT = "P"
        ISNULL(SUM(CASE 
            WHEN eh.EmpStatus = 'L' AND eh.EmpFTPT = 'P' 
            THEN eh.Is_RSA 
            ELSE 0 
        END), 0) AS PT_RSAs_LOA,
        
        -- Current Headcount
        -- Using the most recent employee snapshot (Is_Latest_Run = 1)
        SUM(CASE 
            WHEN eh.Is_Latest_Run = 1 
            THEN ISNULL(eh.Head_Count, 0)
            ELSE 0
        END) AS Current_Headcount
        
    FROM [Retail_DW_Core].[SMQQ_FactEmployeeHistory] eh
    GROUP BY eh.LocationID
)

SELECT 
    tb.LocationID,
    
    -- Act Traffic Last 3 Months
    -- DAX: CALCULATE(SUM(TrafficBudget[Traffic]), FILTER(...))
    SUM(CASE 
        WHEN tb.WeekNum_of_Year >= pv.Start_Week_Act 
             AND tb.WeekNum_of_Year <= pv.End_Week_Act 
        THEN ISNULL(tb.Traffic, 0)
        ELSE 0 
    END) AS Act_Traffic_Last_3_Months,
    
    -- Bud Traffic Last 3 Months
    -- DAX: CALCULATE(SUM(TrafficBudget[Traffic Goal]), FILTER(...))
    SUM(CASE 
        WHEN tb.WeekNum_of_Year >= pv.Start_Week_Act 
             AND tb.WeekNum_of_Year <= pv.End_Week_Act 
        THEN ISNULL(tb.TUGoal, 0)
        ELSE 0 
    END) AS Bud_Traffic_Last_3_Months,
    
    -- Bud Traffic Next 3 Months
    -- DAX: CALCULATE(SUM(TrafficBudget[Traffic Goal]), FILTER(...))
    SUM(CASE 
        WHEN tb.WeekNum_of_Year >= pv.WeekNum_Plus1 
             AND tb.WeekNum_of_Year <= pv.WeekNum_Plus13 
        THEN ISNULL(tb.TUGoal, 0)
        ELSE 0 
    END) AS Bud_Traffic_Next_3_Months,
    
    -- RSA Hours Last 3 Months
    -- DAX: CALCULATE(SUM(TrafficBudget[RSA Hours]), FILTER(...))
    SUM(CASE 
        WHEN tb.WeekNum_of_Year >= pv.Start_Week_Act 
             AND tb.WeekNum_of_Year <= pv.End_Week_Act 
        THEN ISNULL(tb.RSA_Hours, 0)
        ELSE 0 
    END) AS RSA_Hours_Last_3_Months,
    
    -- RSA Hours/Week Last 3 Months
    -- DAX: CALCULATE(SUM(TrafficBudget[Hours / RSA]) / 12, FILTER(...))
    SUM(CASE 
        WHEN tb.WeekNum_of_Year >= pv.Start_Week_Act 
             AND tb.WeekNum_of_Year <= pv.End_Week_Act 
        THEN ISNULL(tb.Hours_per_RSA, 0)
        ELSE 0 
    END) / 12.0 AS RSA_Hours_per_Week_Last_3_Months,
    
    -- FT RSAs
    -- DAX: IF(result = 0, 0, result) - simplified to just return the value
    ISNULL(ers.FT_RSAs_Active, 0) AS FT_RSAs,
    
    -- FT RSAs LOA
    ISNULL(ers.FT_RSAs_LOA, 0) AS FT_RSAs_LOA,
    
    -- PT RSAs
    ISNULL(ers.PT_RSAs_Active, 0) AS PT_RSAs,
    
    -- PT RSAs LOA
    ISNULL(ers.PT_RSAs_LOA, 0) AS PT_RSAs_LOA,
    
    -- Current Headcount
    ISNULL(ers.Current_Headcount, 0) AS Current_Headcount

FROM [Retail_DW_Core].[SMQQ_FactTrafficBudget] tb
CROSS JOIN ParameterValues pv
LEFT JOIN EmployeeRSAStats ers ON tb.LocationID = ers.LocationID
GROUP BY 
    tb.LocationID, 
    ers.FT_RSAs_Active, 
    ers.FT_RSAs_LOA, 
    ers.PT_RSAs_Active, 
    ers.PT_RSAs_LOA, 
    ers.Current_Headcount;