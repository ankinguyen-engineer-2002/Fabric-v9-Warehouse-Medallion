-- Auto Generated (Do not modify) DDE72FC1206170646D151AD456B0362A412449408E8162BBFD477D952AE3BBBF
CREATE   VIEW [Retail_DW_NonCore_Wrk].[V_GLTransactions] AS
SELECT gh.Id,
	   gh.ItemId,
       gh.CustomerKey,
       gh.CustomerType,
       gh.ReferenceNumber,
       gh.PostDate,
       gh.PostTime,
       gh.Operator,
       gh.HeaderComment,
       gh.AccountNumber,
       gh.TransDate,
       gh.Debit,
       gh.Credit,
       gh.Remark,
       Null AS Description,
       gh.YearId,
       CASE
           WHEN gh.Period = 13 THEN
               1
           ELSE
               0
       END AS IsPeriod13
       ,REPLACE(apb.VendorInvoiceNumber, '|',' ')  InvoiceId
FROM [$(Retail_Warehouse)].[Retail_OOM_Enh].[GLHist] AS gh
 --   INNER JOIN [edw_prod].[masterdata_retail].[glpost_source] AS gs 
  --      ON gh.Source = gs.Id 
    LEFT JOIN [$(Source_Data)].[Retail_Corporate].[APBill] AS apb
        ON IIF(gh.CustomerType = 'VEN', gh.ReferenceNumber, NULL) IN ( apb.APBillID )