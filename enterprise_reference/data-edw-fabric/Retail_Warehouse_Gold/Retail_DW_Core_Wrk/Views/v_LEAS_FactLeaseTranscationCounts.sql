
CREATE   VIEW [Retail_DW_Core_Wrk].[v_LEAS_FactLeaseTranscationCounts] AS
SELECT cls.LocationKey,
       cls.SalesPersonKey,
       cls.TransDateKey,
       cls.FinanceProviderID,
       cls.IsLeasedVendor,
       SUM(cls.SUClose) AS SUClose,
       SUM(cls.SPClose) AS SPClose
FROM
(
    SELECT soc.SuperOrderID,
           soc.LocationKey,
           soc.SalesPersonKey,
           soc.TransDateKey,
           MAX(fpm.FinanceProviderID) AS FinanceProviderID,
           MAX(fpm.IsLeasedVendor) AS IsLeasedVendor,
           SUM(soc.SuperOrderClose) AS SUClose,
           SIGN(SUM(soc.SPClose)) AS SPClose,
           oh.IsFinanced
    FROM [Retail_DW_Core].[FactCloses] AS soc
        INNER JOIN [Retail_DW_Core].[FactSalesOrderHeader] AS oh
            ON oh.SourceOrderID = soc.SourceOrderID
        LEFT OUTER JOIN [Retail_DW_Core].[DimPaymentType] AS pt  
            ON pt.PaymentTypeID = oh.PaymentTypeID
        LEFT OUTER JOIN [$(Source_Data)].[Retail_External].[FinanceProviderMapping] AS fpm
            ON fpm.FinanceProviderID = pt.VendorID
    WHERE soc.TransDateKey >= CONCAT(YEAR(GETDATE())-2,'0101')
    GROUP BY soc.SuperOrderID,
             soc.LocationKey,
             soc.SalesPersonKey,
             soc.TransDateKey,
             oh.IsFinanced
) cls
GROUP BY cls.LocationKey,
         cls.SalesPersonKey,
         cls.TransDateKey,
         cls.FinanceProviderID,
         cls.IsLeasedVendor;
GO

