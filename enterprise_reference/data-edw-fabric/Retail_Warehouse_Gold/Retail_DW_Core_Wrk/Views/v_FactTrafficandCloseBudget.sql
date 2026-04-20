-- Auto Generated (Do not modify) D514849CF72FF14DFF0A9B346CBEABD93AC10F83748A8794D539770B13A22DBD
CREATE VIEW [Retail_DW_Core_Wrk].[v_FactTrafficandCloseBudget]
AS

/* OLD SCRIPT
SELECT
	LocationID AS StoreID
	, TransDate
	, TUGoal
	, CloseGoal
	, RUGoal
FROM [$(Source_Data)].[Retail_Miniapps].[TrafficBudget];
*/
SELECT
    A.LocationID AS StoreID,
    CAST(A.TransDate AS DATE) AS TransDate,
    A.TUGoal,
    A.CloseGoal,
    A.RUGoal
FROM [$(Source_Data)].[Retail_Miniapps].[TrafficBudget] A
LEFT JOIN (
    SELECT DISTINCT 
        StoreID,
        StoreType
		FROM
    [Retail_DW_Core].[FactFinancialBudget]  
) S ON A.LocationID = S.StoreID
WHERE A.TransDate <=
CASE 
        WHEN S.StoreType = 'Red' THEN CAST('2025-12-31' AS DATE)
        WHEN S.StoreType = 'Yellow' THEN CAST('2025-12-27' AS DATE)
        ELSE CAST('2025-12-27' AS DATE)
END

UNION ALL

SELECT
    StoreID,
    CAST(BudgetDate AS DATE) AS TransDate,
    Derivedups AS TUGoal,
    (Derivedups * CloseRatio) AS CloseGoal,
    NULL AS RUGoal
FROM [Retail_DW_Core].[FactFinancialBudget]
WHERE BudgetDate >
CASE 
        WHEN StoreType = 'Red' THEN CAST('2025-12-31' AS DATE)
        WHEN StoreType = 'Yellow' THEN CAST('2025-12-27' AS DATE)
END