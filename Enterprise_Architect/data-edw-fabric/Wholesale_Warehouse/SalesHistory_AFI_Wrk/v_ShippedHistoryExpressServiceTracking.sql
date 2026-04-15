CREATE VIEW SalesHistory_AFI_Wrk.[v_ShippedHistoryExpressServiceTracking]
  AS 
    SELECT  T1.TSEINV                    AS InvoiceNumber,
            T1.TSEORDER                  AS OrderNumber,
            T1.TSEISEQ                   AS ItemSequenceNumber,
            T1.TSEITEM                   AS tseItemNumber ,    
            CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate],
            CAST(CAST(T2.INCSNO AS INT)  AS CHAR(8))   AS CustomerNumber,
            T3.SSSPNO                    AS ShiptoNumber, 
            T1.TSESEQ                    AS TrackingSeqNumber,
            CAST(T1.TSETRACK AS VARCHAR (40))   AS TrackingNumber,
            CAST(T1.TSECARRIR AS VARCHAR(15))  AS Carrier,
            T1.TSEDMSLVL                 AS DeliveryMethodServiceLevel,
            CAST(CAST(T1.TSESERNO AS BIGINT) AS VARCHAR(15))  AS SerialNumber,
            T1.TSEFRTCHG                 AS FreightCharge         
        FROM 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSESTR T1                    
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ T2 
                ON T2.ININVR=T1.TSEINV and T2.INORNO=T1.TSEORDER                  
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3 
                ON T2.ININVR = T3.SSINVR AND T2.INORNO=T3.SSORNO        
       WHERE T2.INDFCD <> 1 
