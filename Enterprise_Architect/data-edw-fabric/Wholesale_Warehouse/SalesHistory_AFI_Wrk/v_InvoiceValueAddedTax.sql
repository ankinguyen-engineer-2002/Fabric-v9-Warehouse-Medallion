CREATE VIEW SalesHistory_AFI_Wrk.[v_InvoiceValueAddedTax]
  AS 
      SELECT  CAST(CAST(T2.INCSNO AS INT) AS char(8)) AS CustomerNumber ,
              T3.SSSPNO                  AS ShiptoNumber,
              T1.TXINVR                  AS InvoiceNumber,
              T1.TXORNO                  AS OrderNumber,
              CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate],
              T1.TXTXBC                  AS TaxCode,
              T1.TXTXA1                  AS TaxAmount,
              T1.TXPSCD                  AS TaxPostCode
          FROM 
              [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ T2 
          JOIN 
              [$(Source_Data)].[Wholesale_Invoicing_AFI].TSTXIN T1 
                  ON T2.ININVR = T1.TXINVR AND T2.INORNO = T1.TXORNO 
          JOIN 
              [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3 
                  ON T2.ININVR = T3.SSINVR AND T2.INORNO = T3.SSORNO 
      WHERE   T2.INDFCD <> 1   