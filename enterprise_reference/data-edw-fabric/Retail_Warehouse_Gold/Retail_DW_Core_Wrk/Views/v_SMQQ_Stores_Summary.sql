-- Auto Generated (Do not modify) 51B4AB92BF314263BC4D4460C608B049C34A0C9D402C502EB7FF170030BD574A
/* 
09/09/2025 || Harshit S: Created View
*/
CREATE     VIEW [Retail_DW_Core_Wrk].[v_SMQQ_Stores_Summary] AS

SELECT 
    eh.LocationID,
    
    -- CY Hires = SUM('Employee History'[CY Hires])
    SUM(ISNULL(eh.CY_Hires, 0)) AS CY_Hires,
    
    -- CY Separations = SUM('Employee History'[CY Separations])
    SUM(ISNULL(eh.CY_Separations, 0)) AS CY_Separations,
    
    -- Head Count = SUM('Employee History'[Head Count])
    SUM(ISNULL(eh.Head_Count, 0)) AS Head_Count,
    
    -- FT Equivalent = SUM('Employee History'[FT Equivalent])
    SUM(ISNULL(eh.FT_Equivalent, 0)) AS FT_Equivalent,
    
    -- FT EEs = CALCULATE(COUNT('Employee History'[EmpFTPT]), 'Employee History'[EmpFTPT] = "F", 'Employee History'[EmpStatus] <> "T")
    COUNT(CASE 
        WHEN eh.EmpFTPT = 'F' AND eh.EmpStatus <> 'T' 
        THEN eh.EmpFTPT 
        ELSE NULL 
    END) AS FT_EEs,
    
    -- PT EEs = CALCULATE(COUNT('Employee History'[EmpFTPT]), 'Employee History'[EmpFTPT] = "P", 'Employee History'[EmpStatus] <> "T")
    COUNT(CASE 
        WHEN eh.EmpFTPT = 'P' AND eh.EmpStatus <> 'T' 
        THEN eh.EmpFTPT 
        ELSE NULL 
    END) AS PT_EEs,
    
    -- PW Hires = SUM('Employee History'[CW Hires])
    SUM(ISNULL(eh.CW_Hires, 0)) AS PW_Hires,
    
    -- PW Separations = SUM('Employee History'[CW Separations])
    SUM(ISNULL(eh.CW_Separations, 0)) AS PW_Separations

FROM [Retail_DW_Core].[SMQQ_FactEmployeeHistory] eh
WHERE eh.Is_Latest_Run = 1 
      AND eh.Is_RSA <> 0 
      AND eh.LocationID IS NOT NULL 
      AND eh.LocationID <> ''
GROUP BY eh.LocationID