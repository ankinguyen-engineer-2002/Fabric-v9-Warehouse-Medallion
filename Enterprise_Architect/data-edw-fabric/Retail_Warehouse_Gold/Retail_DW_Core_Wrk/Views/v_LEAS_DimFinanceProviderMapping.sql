CREATE   VIEW [Retail_DW_Core_Wrk].[v_LEAS_DimFinanceProviderMapping]
AS
SELECT DISTINCT
       fp.FinanceProviderID,
       fp.Name,
       COALESCE(fpm.IsLeasedVendor, 0) AS IsLeasedVendor
FROM [$(Source_Data)].[Retail_External].[FinanceProviderMapping] AS fpm
    INNER JOIN [Retail_DW_Core].[FinanceProvider]  AS fp
        ON fp.FinanceProviderID = fpm.FinanceProviderID
WHERE fp.FinanceProviderID IS NOT NULL;
GO

