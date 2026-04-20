CREATE VIEW SalesHistory_AFI_Wrk.[v_InvoiceHeader]
AS
    SELECT
            CAST(CAST(T1.INCSNO AS INT) AS CHAR(8))   AS CustomerNumber,
            ISNULL(T2.SSSPNO, '')        AS ShiptoNumber,
            T1.ININVR                    AS InvoiceNumber,
            T1.INORNO                    AS OrderNumber,
            T1.INPONO                    AS PurchaseOrder,
            T1.INWHSE                    AS Warehouse,
            T1.INIVAM                    AS InvoiceAmount,
            ISNULL(T2.SSSPNM, '')        AS ShiptoName,
            ISNULL(T2.SSSPA1, '')        AS ShiptoAddress1,
            ISNULL(T2.SSSPA2, '')        AS ShiptoAddress2,
            ISNULL(T2.SSSPA3, '')        AS ShiptoCity,
            ISNULL(T2.SSSPST, '')        AS ShiptoState,
            ISNULL(T2.SSSPZC, '')        AS ShiptoZipCode,
            CAST(CAST(T1.INSLNO AS INT) AS CHAR(5))   AS ShiptoSalesman,
            CAST(CAST(T1.INPSMN AS INT) AS CHAR(2))   AS PostingMonth,
            ISNULL(T3.XORDAR, '')        AS OrderArrivalCode,
            ISNULL(T3.XADVTS, '')        AS AdvertisingFlag,
            ISNULL(T3.XORDTY, '')        AS OrderType,
            CASE
                WHEN T1.INRQDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T1.INRQDT AS INT)) AS DATE)
            END                          AS RequestDate,
            CASE
                WHEN T1.INORDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T1.INORDT AS INT)) AS DATE)
            END                          AS OrderDate,
            CAST(STR(T1.INIVDT) AS DATE) AS InvoiceDate,
            CAST(T1.INCNNO AS INT)       AS LeadTime,
            T3.XNTRPN                    AS TripNumber,
            T1.INTXA1                    AS TaxAmount,
            ISNULL(T3.XDROP#,0)         AS DropNumber,
            T3.XOTYP1                    AS OrderTypePrimary,
            T3.XOTYP2                    AS OrderTypeSecondary,
            T3.XOTYP3                    AS OrderTypeUsrDefine3,
            T3.XOTYP4                    AS OrderTypeUsrDefine4,
            T1.INSHIN                    AS ShipInstructions,
            T4.INWGHT                    AS ShipWeight,
            T1.INTMPC                    AS TermsDiscount,
            CAST(STR(T5.BHCDAT) as date) AS TripCreatedDate,
            T1.INCRCD                    AS CreditCode,
            'USD'                        AS CurrencyCode,
            T3.XPROM#                   AS PromotionNumber,
            T3.XCAPR#                   AS CreditApprovalNBR,
            T2.SSSTNM                    AS SoldtoName,
            T2.SSSPCN                    AS ShiptoCountryName,
            T6.CAHSEQ               AS [Sequence]
    FROM
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ      T1
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN      T2
                ON T1.ININVR = T2.SSINVR
                   AND T1.INORNO = T2.SSORNO
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSINXN      T3
                ON T1.ININVR = T3.XNINVR
                   AND T1.INORNO = T3.XNORNO
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].INVORD      T4
                ON T1.ININVR = T4.ININV#
                   AND T1.INORNO = T4.INORD#
        LEFT JOIN
            [$(Source_Data)].[Wholesale_Codis_AFI].Bttriph T5 
                ON T3.XNTRPN = T5.BHTRPNO
       LEFT JOIN 
            (SELECT DISTINCT 
               CAHInvoiceNumber, 
               CAHOrderNumber, 
               CAST(CAHSequence AS INT) AS CAHSEQ
            FROM 
                [$(Source_Data)].[Wholesale_Invoicing_AFI].TSCAIN 
             WHERE CAHSequence = 0) T6
                 ON T1.ININVR=T6.CAHInvoiceNumber  AND T1.INORNO=T6.CAHOrderNumber   

     