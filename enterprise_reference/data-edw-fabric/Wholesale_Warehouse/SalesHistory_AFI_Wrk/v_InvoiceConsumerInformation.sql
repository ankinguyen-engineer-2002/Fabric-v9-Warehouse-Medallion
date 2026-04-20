CREATE VIEW SalesHistory_AFI_Wrk.v_InvoiceConsumerInformation
AS
    SELECT
            T1.CAHInvoiceNumber                            AS InvoiceNumber,
            CAST(T1.CAHOrderNumber AS VARCHAR(10))        AS OrderNumber,
            CAST(T1.CAHSalesOrderNumber AS VARCHAR(30))       AS SalesOrderNumber,
            T1.CAHSequence                               AS [Sequence],
            CAST(T1.CAHConsumerLastName AS VARCHAR(50))         AS ConsumerLastName,
            CAST(T1.CAHConsumerFirstName  AS VARCHAR(50))        AS ConsumerFirstName,
            CAST(T1.CAHConsumerAddress1 AS VARCHAR(35))         AS ConsumerAddress1,
            CAST(T1.CAHConsumerAddress2 AS VARCHAR(35))         AS ConsumerAddress2,
            CAST(T1.CAHConsumerAddress3 AS VARCHAR(35))         AS ConsumerAddress3,
            CAST(T1.CAHConsumerAddress4 AS VARCHAR(35))         AS ConsumerAddress4,
            CAST(T1.CAHConsumerAddress5 AS VARCHAR(35))         AS ConsumerAddress5,
            CAST(T1.CAHCity AS VARCHAR(50))         AS City,
            CAST(T1.CAHState AS CHAR(2))            AS [State],
            CAST(T1.CAHZipcode AS VARCHAR(12))       AS ZipCode,
            CAST(T1.CAHCountry AS CHAR(3))            AS Country,
            CAST(T1.CAHHomePhone AS VARCHAR(20))         AS HomePhone,
            CAST(T1.CAHCellPhone AS VARCHAR(20))         AS CellPhone,
            CAST(T1.CAHWorkPhone AS VARCHAR(20))         AS WorkPhone,
            CAST(T1.CAHConsumerNumber AS VARCHAR(40))      AS ComsumerNumber,
            T1.CAHGeocodeLatitude                            AS GeoCodeLatitute,
            T1.CAHGeocodeLongitude                            AS GeoCodeLongitude,
            CAST(T1.CAHEmailAddress AS VARCHAR(75))     AS MailAddress,
            CAST(T1.CAHDeliveryMethod AS CHAR(3))          AS DeliveryMethod,
            CAST(CAST(T2.INCSNO AS INT) AS CHAR(8)) AS CustomerNumber,
            CAST(T3.SSSPNO AS CHAR(4))              AS ShiptoNumber,
            CASE WHEN CAST(  T2.INIVDT as INT) = 0 THEN NULL ELSE CAST(CAST(CAST(  T2.INIVDT as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate]
       FROM
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSININ    T2
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSCAIN    T1
                ON T2.ININVR = T1.CAHInvoiceNumber
                   AND T2.INORNO = T1.CAHOrderNumber
                  
        JOIN
            [$(Source_Data)].[Wholesale_Invoicing_AFI].TSSSIN    T3
                ON T2.ININVR = T3.SSINVR
                   AND T2.INORNO = T3.SSORNO
    WHERE
            T2.INDFCD <> 1;