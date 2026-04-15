CREATE VIEW SalesHistory_AFI_Wrk.[v_ShippedHistoryCommAdjustment]
  AS
    SELECT  T1.CDHInvoiceNumber                     AS InvoiceNumber,
            T1.CDHOrderNumber                      AS OrderNumber,
            T1.CDHItemNumber                      AS ItemSKU,
            T1.CDHItemSequence                     AS ItemSequence,
            T1.CDHCommissionAdjustmentCode                    AS CommissionAdjustmentCode,
            T1.CDHExceptionAmount                       AS ExceptionAmount,           
            T1.CDHExceptionID                     AS ExceptionId,
            T1.CDHPriceCode                      AS PriceCode,
            CAST(CAST(T2.INCSNO AS INT) AS CHAR(8))       AS CustomerNumber,
            T3.SSSPNO                        AS ShiptoNumber,  
            CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate]
   
        FROM    
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ T2 
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].[TSCMADJ] T1
                ON T2.ININVR=T1.CDHInvoiceNumber AND T2.INORNO=T1.CDHOrderNumber
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3
                ON T2.ININVR = T3.SSINVR AND T2.INORNO=T3.SSORNO
        WHERE T2.INDFCD <> 1 