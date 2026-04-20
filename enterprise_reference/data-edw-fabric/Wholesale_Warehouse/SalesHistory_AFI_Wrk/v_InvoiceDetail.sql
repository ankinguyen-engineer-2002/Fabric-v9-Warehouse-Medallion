CREATE VIEW SalesHistory_AFI_Wrk.[v_InvoiceDetail]
AS

   
    SELECT 
            CAST(CAST(T2.ITCSNO AS INT) AS CHAR(8))    AS CustomerNumber,
            T2.ITINVR                     AS InvoiceNumber,
            T2.ITITNO                     AS ItemNumber,
            T2.ITITSQ                     AS ItemSequence,
            T2.ITSHQT                     AS QuantityShipped,
            T2.ITPRIC                     AS InvoiceAmount,
            T2.ITORNO                     AS OrderNumber,
            T2.ITSPNO                     AS ShiptoNumber,
            T2.ITORQT                     AS QuantityOrdered,
            T2.ITBOQT                     AS QuantityBackOrdered,
            T2.ITCRCD                     AS CreditCode,
            T1.INWHSE                     AS Warehouse,
            CAST(CAST(T3.XSLSN1 AS INT) AS CHAR(5))    AS BilltoSalesman,
            CAST(CAST(T3.XSLSN2 AS INT) AS CHAR(5))    AS ShiptoSalesman,
            T3.XDSCNT                     AS Discount,
            T3.XTCONF                     AS PriceAdjustment,
            CAST(CAST(T1.INPSMN AS INT) AS CHAR(2))    AS PostingMonth,
            T3.XFRGHT                     AS Freight,
            T2.ITPRIC                     AS Price,
            T2.ITITCL                     AS ItemClass,
            CAST(CAST(T3.XTINVR AS INT) AS VARCHAR(9)) AS ExtendedInvoiceNumber,
            T1.INPONO                     AS PurchaseOrder  ,
            CASE
                WHEN T1.INRQDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T1.INRQDT AS INT)) AS DATE)
            END                           AS RequestDate,
            CASE
                WHEN T1.INIVDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T1.INIVDT AS INT)) AS DATE)
            END                           AS InvoiceDate  ,
            ''                            AS DefaultDeliveryDays,
            T4.XNTRPN                     AS TripNumber,
            T4.XDROP#                    AS DropNumber,
            CASE
                WHEN T3.XPRMDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T3.XPRMDT AS INT)) AS DATE)
            END                           AS PromiseDelivery,
            CASE
                WHEN T1.INORDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T1.INORDT AS INT)) AS DATE)
            END                           AS OrderEntry,
            T3.XPRTY                      AS PriorityCode,
            ' '                           AS OrderItemStatus,
            T3.XORDPRTY                   AS OrderPriority,
            CASE
                WHEN T4.XOCRDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T4.XOCRDT AS INT)) AS DATE)
            END                           AS OriginalRequestDate ,
            CAST(NULL AS DATE)            AS ActualDelivery,
            T2.ITSNUM                     AS CustomerSku,
            T3.XLNRL                      AS LineReleaseNumber,
            T2.ITNTSL                     AS NetSales,
            T3.XFOBPR                     AS StanardPrice,
            T3.XCOOPA                     AS AdvertisingAccrual,
            T3.XDFIDC                     AS DFIDicsount,
            T3.XCONPR                     AS ContractPrice,
            'USD'                         AS CurrencyCode,
            --- Thse next 4 columns get updated by usp_Update_InvoiceDetail_DeliveryDates (the actual delivery dates may not arrive for up to a week after invoicing)
            NULL                          AS DeliveryDays,
            NULL                          AS DeliveryDaysOriginalPromiseDate,
            NULL                          AS DeliveryDaysRaw,
            NULL                          AS DeliveryDaysOriginalPromiseDateRaw,
          --- Thse next 6 columns get updated by usp_Update_InvoiceDetail  (logic pulls from QualtiyCostDetail)
            NULL                          AS OriginalInvoiceNumber,
            CAST(NULL AS DATE)            AS OriginalInvoiceDate,
            NULL                          AS OriginalOrderNumber,
            CAST(NULL AS DATE)            AS OriginalOrderDate,
            NULL                          AS OriginalSequenceNumber,
            NULL                          AS OriginalDeliveryMethod,
            T4.XOTYP2                     AS OrderType  ,
            CASE
                WHEN T1.INORDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T1.INORDT AS INT)) AS DATE)
            END                           AS OrderDate,
            CASE
                WHEN T3.XPRMDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T3.XPRMDT AS INT)) AS DATE)
            END                           AS OriginalPromiseDate,
            CASE
                WHEN T1.INRQDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T1.INRQDT AS INT)) AS DATE)
            END                           AS CurrentRequestDate,
            CASE
                WHEN T3.XPDISD = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T3.XPDISD AS INT)) AS DATE)
            END                           AS DeliveryDate ,
            CASE
                WHEN T5.BHZDAT = 0
                    THEN
                    NULL
                ELSE
                     CAST(STR(CAST(T5.BHZDAT AS INT)) AS DATE)
            END                           AS TripCloseDate ,  
            CASE
                WHEN T5.BHSDAT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T5.BHSDAT AS INT)) AS DATE)
            END                           AS FirstScanDate ,  
            CASE
                WHEN T5.BHCDAT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T5.BHCDAT AS INT)) AS  DATE)
            END                           AS TripCreateDate,  
            CASE
                WHEN T2.ITIDDT = 0
                    THEN
                    NULL
                ELSE
                    CAST(STR(CAST(T2.ITIDDT AS INT)) AS DATE)
            END                           AS CurrentPromiseDate,
            T3.XPRCCD                     AS PriceCode,
            T3.XDSCCD                     AS DiscountCode,
            T3.XCOMCD                     AS CommissionCode,
            T3.XFRTCD                     AS FreightCode,
            T3.XDSCSC                     AS DiscountSalesClass,
            T3.XEXCID                     AS ExceptionID,
            T3.XFSLSC                     AS FreightSalesClass,
            T3.XGBCOD                     AS BuyGroupCode,
            T3.XGRPID                     AS GroupPricingExceptionID,
            T3.XWHSOP                     AS WarehouseOperationPercent,
            T3.XPRICE                     AS PriceAdderPercent,
            T3.XPALLW                     AS CalculatedAllowancePercent,
            T3.XPKGDA                     AS PackageDiscountAllocationPercent,
            T3.XPKGDES                    AS PackageDescription,
            T3.XPKGID                     AS PackageID,
            T3.XPKGPRC                    AS PackagePrice,
            T3.XPKITM$                     AS PackageItemPrice,
            T3.XPKITM$                   AS PackageItemDiscount,
            T4.XOTYP3                     AS OrderType3

    FROM
 
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ T1
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSITIN T2
                ON T1.ININVR = T2.ITINVR
                   AND T1.INORNO = T2.ITORNO
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSITXN T3
                ON T2.ITINVR = T3.XTINVR
                   AND T2.ITORNO = T3.XTORNO
                   AND T2.ITITNO = T3.XTITNO
                   AND T2.ITITSQ = T3.XTITSQ
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSINXN T4
                ON T1.ININVR = T4.XNINVR
                   AND T1.INORNO = T4.XNORNO
        JOIN 
            [$(Source_Data)].[Wholesale_Codis_AFI].Bttriph T5 
                ON T4.XNTRPN = T5.BHTRPNO

    WHERE
            T2.ITINVR IS NOT NULL;

          
          
       