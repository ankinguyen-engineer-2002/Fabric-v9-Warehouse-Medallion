CREATE VIEW SalesHistory_AFI_Wrk.[v_ShippedHistoryDiscounts]
  AS 
    Select  T1.DCHINVNBR                AS InvoiceNumber ,
            T1.DCHORDNO                 AS OrderNumber , 
            T1.DCHITMSEQ                AS ItemsSquence , 
            T1.DCHDSCTYP                AS DiscountType ,
            T1.DCHDSCADJC               AS DiscountaAjustmentCode , 
            T1.DCHITMNBR                AS ItemSKU ,
            T1.DCHAMOUNT                AS Amount ,  
            T1.DCHRATIOA                AS RatioAmount ,       
            T1.DCHDSCPCT                AS DiscountPercent ,  
            T1.DCHEXCPTID               AS ExceptionId , 
            T1.DCHDSCCDE                AS DiscountCode , 
            T1.DCHDSCSLSC               AS DiscountClass,
            CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate],
            CAST(CAST(T2.INCSNO AS INT) AS CHAR(8))  AS CustomerNumber,  
            T3.SSSPNO                   AS ShipToNumber     
        From 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSDSCADJ  T1 
        Join  
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ  T2 
                ON T1.DCHINVNBR=T2.ININVR and T1.DCHORDNO=T2.INORNO  
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3 
                ON T2.ININVR = T3.SSINVR AND T2.INORNO = T3.SSORNO  
    WHERE T2.INDFCD <> 1 

