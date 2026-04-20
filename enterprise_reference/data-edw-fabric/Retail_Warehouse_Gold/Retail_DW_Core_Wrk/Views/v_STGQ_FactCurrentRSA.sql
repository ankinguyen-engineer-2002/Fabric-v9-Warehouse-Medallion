-- Auto Generated (Do not modify) 5EAC2968F628C600BD817F301680B9ECC3544684D4D38EE58F52837E99EA2198
/*
2025-09-02 || Harshit S:  Created View

*/

CREATE     VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactCurrentRSA] AS
SELECT 
    EH.[LocationID],
    
    -- Head Count (calculated from EmpStatus)
    SUM(CASE WHEN EH.EmpStatus = 'A' THEN 1 ELSE 0 END) AS [Head Count],
    
    -- Head Count LOA (calculated from EmpStatus)
    SUM(CASE WHEN EH.EmpStatus = 'L' THEN 1 ELSE 0 END) AS [Head Count LOA]

FROM [Retail_DW_Core].[STGQ_FactEmployeeHistory] EH
WHERE EH.Is_Latest_Run = 1          
    AND EH.Is_RSA = 1              
    AND EH.LocationID IS NOT NULL   
GROUP BY EH.[LocationID];