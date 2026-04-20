-- Auto Generated (Do not modify) EEE5867BA030FAFFEAE3FE9B1E574478875F910AE566CE40071EB41224717807
CREATE VIEW [Retail_DW_Core_Wrk].[v_FactSalesBudget]
AS

/*
OLD SCRIPT

SELECT
	LocationID AS StoreID
	, CAST(TransDate AS DATETIME) AS TransDate
	, CAST(DateCreated AS DATETIME) AS DateCreated
	, CategoryID
	, GroupID
	, WrittenSales
	, WrittenGM
	, DeliveredSales
	, DeliveredGM
	, PrimaryCategory
FROM [$(Source_Data)].[Retail_Miniapps].[SalesBudget];
*/
SELECT
	LocationID AS StoreID
	, CAST(TransDate AS DATE) AS TransDate
	, CAST(DateCreated AS DATE) AS DateCreated
	, CategoryID
	, GroupID
	, WrittenSales
	, WrittenGM
	, DeliveredSales
	, DeliveredGM
	, PrimaryCategory
FROM [$(Source_Data)].[Retail_Miniapps].[SalesBudget] A
LEFT JOIN (
    SELECT DISTINCT 
        StoreID,
        StoreType
        FROM [Retail_DW_Core].[FactFinancialBudget]  
) S ON A.LocationID = S.StoreID
WHERE A.TransDate <=
CASE 
        WHEN S.StoreType = 'Red' THEN CAST('2025-12-31' AS DATE)
        WHEN S.StoreType = 'Yellow' THEN CAST('2025-12-27' AS DATE)
        ELSE CAST('2025-12-27' AS DATE)
END

UNION ALL

SELECT
    StoreID AS StoreID,
    cast(BudgetDate as DATE) as TransDate,
    cast(LastUpdateDate as DATE) as DateCreated,
    NULL as CategoryID,
    NULL as GroupID,
    BudgetWrittenSales as WrittenSales,
    (BudgetWrittenSales - BudgetWrittenCogs) as WrittenGM,
    BudgetInvoicedSales as DeliveredSales,
    (BudgetInvoicedSales - BudgetInvoicedCogs) as DeliveredGM,
    1  as PrimaryCategory
FROM [Retail_DW_Core].[FactFinancialBudget]  
WHERE BudgetDate >
CASE 
        WHEN StoreType = 'Red' THEN CAST('2025-12-31' AS DATE)
        WHEN StoreType = 'Yellow' THEN CAST('2025-12-27' AS DATE)
END

UNION all

SELECT  
    StoreID,
    cast(BudgetDate as date) as TransDate,
    cast(LastUpdateDate as DATE) as DateCreated,
    'DLVY' as CategoryID,
    NULL as GroupID,
    BudgetDeliveryIncomeWrittenSales as WrittenSales,
    0.00 as WrittenGM,
    BudgetDeliveryIncomeInvoicedSales as DeliveredSales,
    0.00 as DeliveredGM,
    0 as PrimaryCategory
FROM [Retail_DW_Core].[FactFinancialBudget]
WHERE BudgetDate >
CASE 
        WHEN StoreType = 'Red' THEN CAST('2025-12-31' AS DATE)
        WHEN StoreType = 'Yellow' THEN CAST('2025-12-27' AS DATE)
END