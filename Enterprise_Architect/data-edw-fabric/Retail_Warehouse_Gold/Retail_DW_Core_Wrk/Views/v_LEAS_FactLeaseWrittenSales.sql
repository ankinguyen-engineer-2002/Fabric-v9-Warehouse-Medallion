CREATE   VIEW [Retail_DW_Core_Wrk].[v_LEAS_FactLeaseWrittenSales] AS
SELECT sdt.TransDateKey,
       sdt.SalesPersonKey,
       sdt.LocationKey,
       COALESCE(fpm.IsLeasedVendor, 0) AS IsLeasedVendor,
       fpm.FinanceProviderID,
       pt.PaymentTypeID,
       pt.PaymentTypeName,
       SUM(sdt.Sales) AS WrittenSales,
	   SUM(sdt.Sales*oh.IsFinanced) AS FinWrittenSales
FROM [Retail_DW_Core].[FactSales] AS sdt
    INNER JOIN [Retail_DW_Core].[FactSalesOrderHeader] AS oh
        ON oh.SourceOrderID = sdt.OrderID
    LEFT OUTER JOIN [Retail_DW_Core].[DimPaymentType] AS pt
        ON pt.PaymentTypeID = oh.PaymentTypeID
    LEFT OUTER JOIN [$(Source_Data)].[Retail_External].[FinanceProviderMapping] AS fpm
        ON fpm.FinanceProviderID = pt.VendorID
WHERE sdt.TransDateKey >= CONCAT(YEAR(GETDATE())-2,'0101')
      AND sdt.SalesDataTypeKey IN ( 1, 10 )
GROUP BY COALESCE(fpm.IsLeasedVendor, 0),
         sdt.TransDateKey,
         sdt.SalesPersonKey,
         sdt.LocationKey,
         fpm.FinanceProviderID,
         pt.PaymentTypeID,
         pt.PaymentTypeName;
GO

