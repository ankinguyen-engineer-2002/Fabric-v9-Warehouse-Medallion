CREATE VIEW SalesHistory_AFI_Wrk.[v_InvoiceDetailProperties]
  AS
      SELECT  T1.SHEInvoiceNumber               AS InvoiceNumber,
              T1.SHEOrderNumber                AS OrderNumber,
              T1.SHEItemequence               AS ItemSequence,
              T1.SHEFieldName               AS FieldName,
              T1.SHEFieldValue               AS FieldValue,
              CAST(CAST(T2.INCSNO AS INT) AS char(8)) AS CustomerNumber ,
              T3.SSSPNO                  AS ShiptoNumber, 
              CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate]
        FROM 
              [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ T2     
        JOIN 
              [$(Source_Data)].[Wholesale_Invoicing_AFI].TSEXIN T1
                  ON T2.ININVR=T1.SHEInvoiceNumber  AND T2.INORNO=T1.SHEOrderNumber
        JOIN
              [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3
                  ON T2.ININVR = T3.SSINVR AND T2.INORNO=T3.SSORNO
      WHERE T2.INDFCD <> 1   