CREATE VIEW SalesHistory_AFI_Wrk.v_ItemComments 
AS
    SELECT  T1.CIINVR                  AS InvoiceNumber,    
            T1.CIORNO                  AS OrderNumber ,    
            T1.CIITNO                  AS ItemSKU,    
            T1.CIITSQ                  AS ItemSequence  ,    
            T1.CIICSQ                  AS ItemCommentsequence  ,    
            CAST(T1.CIICM1 as VARCHAR(25)) AS ItemComments1,  
            CAST(T1.CIICM2 as VARCHAR(25)) AS ItemComments2,  
            CAST(T1.CIICM3 as VARCHAR(25)) AS ItemComments3,   
            CAST(CAST(T2.INCSNO AS INT) AS char(8)) AS CustomerNumber ,    
            T3.SSSPNO                  AS ShiptoNumber,   
            CAST(CAST(T2.INPSMN AS INT) AS char(2)) AS PostingMonth ,
            CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate]
        FROM 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ T2      
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSCIIN T1    
                ON T2.ININVR=T1.CIINVR     AND T2.INORNO=T1.CIORNO     
        JOIN 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN T3    
                ON T2.ININVR = T3.SSINVR    AND T2.INORNO=T3.SSORNO   
          WHERE T2.INDFCD <> 1 