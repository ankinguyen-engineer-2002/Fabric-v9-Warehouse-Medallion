-- Auto Generated (Do not modify) F10F8D345F925D90D9A9BBCF53CBA1E2EAA12A0A3108A33445858EF1FC87BF3F

CREATE VIEW [PowerBI_Retail_Wrk].[v_PROM_FactOrderDetail]
AS

   SELECT
    O.SourceOrderID,
    O.BaseOrderID,
    O.SKU,
    O.ProductKey,
    O.QuantityOrdered,
    ISNULL(O.UnitListPrice, 0) AS UnitListPrice,
    --ISNULL(O.UnitPromoPrice, 0) AS UnitPromoPrice,
    O.UnitSellPrice,
    ISNULL(O.ProductDiscountAmount, 0) AS UnitOtherDiscount,
    ISNULL(O.ProductDiscountAmount, 0) *  O.QuantityOrdered AS OtherDiscount,
    O.UnitCost,
    -- ISNULL(O.VendorRebate, 0) AS VendorRebate,
    O.ProductDiscountCode,
    O.SpecialOrderFlag,
    O.AsIsReasonCodeID,
    O.WrittenDate,
    R.ReasonCodeID,
    R.ReasonCodeName,
    O.PriceOverrideStaffID,
    S.[SalesPersonName] AS OverrideStaffName,
    G.CategoryID,
    G.GroupID,
    P.SeriesID,
    P.VendorStyle,
    O.StoreID,
    OH.SalesPersonID,
    S2.[SalesPersonName] AS SalespersonName,
    OH.PriceExceptionComment,
    --O.BrandDiscountID,
    --O.BrandDiscountPct,
    CM.FullName AS CustomerName,
    CM.CustomerID,
    -- O.QuantityOrdered * (O.UnitCost - ISNULL(O.VendorRebate, 0)) AS Cost,
    -- CASE 
    --     WHEN ISNULL(O.UnitPromoPrice, 0) <> 0 THEN 
    --         O.QuantityOrdered * ISNULL(O.UnitPromoPrice, 0)
    --     ELSE 
    --          O.QuantityOrdered * ISNULL(O.UnitListPrice, 0) 
    -- END AS FirstPromoPrice,
    O.QuantityOrdered * ISNULL(O.UnitListPrice, 0) AS RetailPrice,
    ISNULL(O.UnitListPrice, 0) AS UnitRetailPrice,
    O.QuantityOrdered * O.UnitSellPrice AS SellPrice
    , C.Description AS TransDescription
   
FROM 
    [Retail_DW_Core].[FactOrderDetail] O
    LEFT JOIN [Retail_DW_Core].[DimTransCodeMap]    C
        ON C.TransCodeID = O.TransCodeID
    LEFT JOIN [Retail_DW_Core].[DimReasonCode] R
        ON O.PriceVarianceExceptionReasonCodeID = R.ReasonCodeID
    LEFT JOIN [Retail_DW_Core].[DimSalesPerson] S
        ON O.PriceOverrideStaffID = s.SalesPersonID
    LEFT JOIN [Retail_DW_Core].[DimProductMaster] P
        ON P.ProductKey = O.ProductKey
    LEFT JOIN [Retail_DW_Core].[DimGroupMaster] G
        ON G.GroupID = P.GroupID
    LEFT JOIN  [Retail_DW_Core].[FactSalesOrderHeader] OH
        ON OH.BaseOrderID = O.BaseOrderID
    LEFT JOIN [Retail_DW_Core].[DimSalesPerson] S2
        ON OH.SalesPersonID = S2.SalesPersonID
    LEFT JOIN [Retail_DW_Core].[DimCustomerMaster] CM
        ON CM.CustomerKey = OH.CustomerKey
WHERE 
    O.WrittenDate >= '2025-01-01'
     AND O.LineStatus IN ('Invoiced', 'Written')
    AND O.TransCodeID IN (0, 1, 7) 
    AND G.CategoryID IN ('ACCESS','BEDDI','BEDRO','CASEG','DININ','MOTION','OUTDR','UPHOL','WARRI','WARRT')