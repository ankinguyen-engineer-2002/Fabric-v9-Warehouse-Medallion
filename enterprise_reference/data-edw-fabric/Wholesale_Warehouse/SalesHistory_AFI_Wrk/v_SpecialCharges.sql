CREATE VIEW SalesHistory_AFI_Wrk.v_SpecialCharges
AS
    SELECT  T1.SCINVR                  AS InvoiceNumber, 
            T1.SCORNO                  AS OrderNumber, 
            T1.SCSQNO                  AS SequenceNumber,
            CAST(CAST(T1.SCCSNO AS INT) AS CHAR(8)) AS SCCSNO , 
            CAST(CAST(T1.SCSCCD AS INT) AS CHAR(1)) AS Code,
            T1.SCSCDS                  AS [Description],
            T1.SCSCAM                  AS Amount, 
            CAST(CAST(T2.INPSMN AS INT)  AS CHAR(2)) AS FiscalMonth, 
            T3.SSSPNO                  AS ShiptoNumber,  
            CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate],
            T2.INWHSE                  AS Warehouse,  
            'USD'                      AS CurrencyCode, 
            T1.SCCRCD                  AS CreditCode     
        FROM      
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ  T2         
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSCIN T1 
                ON T2.ININVR=T1.SCINVR AND T2.INORNO=T1.SCORNO       
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3 
                ON T2.ININVR=T3.SSINVR AND T2.INORNO = T3.SSORNO    
   
    WHERE T2.INDFCD <> 1 