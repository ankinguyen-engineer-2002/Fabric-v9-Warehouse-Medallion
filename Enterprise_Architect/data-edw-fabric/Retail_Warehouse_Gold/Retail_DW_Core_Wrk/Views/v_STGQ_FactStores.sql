-- Auto Generated (Do not modify) 71B4C6FE00088C3FD08DA6FD325690838180F0B1988BFE2ABFE5ECAC4E573AEF
/*
2025-09-02 || Harshit S:  Created View

*/

CREATE       VIEW [Retail_DW_Core_Wrk].[v_STGQ_FactStores] AS
SELECT 
    EH.[LocationID],
    
    -- CY Hires
    SUM(EH.CY_Hires) AS [CY Hires],
    
    -- CY Separations  
    SUM(EH.CY_Separations) AS [CY Separations],
    
    -- Head Count
    SUM(EH.Head_Count) AS [Head Count],
    
    -- FT Equivalent
    SUM(EH.FT_Equivalent) AS [FT Equivalent],
    
    -- FT EEs (Full-time Active Employees)
    COUNT(CASE WHEN EH.EmpFTPT = 'F' AND EH.EmpStatus = 'A' THEN 1 END) AS [FT EEs],
    
    -- PT EEs (Part-time Active Employees)
    COUNT(CASE WHEN EH.EmpFTPT = 'P' AND EH.EmpStatus = 'A' THEN 1 END) AS [PT EEs],
    
    -- PW Hires (Current Week Hires)
    SUM(EH.CW_Hires) AS [PW Hires],
    
    -- PW Separations (Current Week Separations)
    SUM(EH.CW_Separations) AS [PW Separations],
    
    -- Head Count LOA
    SUM(EH.Head_Count_LOA) AS [Head Count LOA],
    
    -- FT Equivalent LOA
    SUM(EH.FT_Equivalent_LOA) AS [FT Equivalent LOA],
    
    -- FT EEs LOA (Full-time LOA Employees)
    COUNT(CASE WHEN EH.EmpFTPT = 'F' AND EH.EmpStatus = 'L' THEN 1 END) AS [FT EEs LOA],
    
    -- PT EEs LOA (Part-time LOA Employees)
    COUNT(CASE WHEN EH.EmpFTPT = 'P' AND EH.EmpStatus = 'L' THEN 1 END) AS [PT EEs LOA]

FROM [Retail_DW_Core].[STGQ_FactEmployeeHistory] EH
WHERE EH.Is_Latest_Run = 1          -- Is Latest Run = 1
    AND EH.Is_RSA <> 0             -- Is RSA <> 0  
    AND EH.LocationID IS NOT NULL   -- LocationID <> BLANK()
GROUP BY EH.[LocationID];