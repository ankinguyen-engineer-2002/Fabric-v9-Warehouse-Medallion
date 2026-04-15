CREATE VIEW SalesHistory_AFI_Wrk.v_OrderComments
AS
    SELECT  T1.COINVR                  AS InvoiceNumber,  
            T1.COORNO                  AS OrderNumber,      
            T1.COOCSQ                  AS OrderSequence,    
            T1.COOCM1                  AS OrderComment1,   
            T1.COOCM2                  AS OrderComment2,    
            T1.COOCM3                  AS OrderComment3,   
            CAST(CAST(T2.INCSNO AS INT) AS CHAR(8)) AS CustomerNumber,  
            T3.SSSPNO                  AS ShiptoNumber,
            CAST(CAST(T2.INPSMN AS INT) AS CHAR(2)) AS PostingMonth,                    
            CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS  InvoiceDate    
        FROM 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ T2       
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSCOIN T1    
                ON T2.ININVR = T1.COINVR    AND T2.INORNO = T1.COORNO     
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3     
                ON T2.ININVR = T3.SSINVR    AND T2.INORNO = T3.SSORNO  
    WHERE   T2.INDFCD <> 1   