CREATE VIEW SalesHistory_AFI_Wrk.[v_OrderHistory]
AS
    WITH InvoiceHeader_Wrk
    AS (
           SELECT
               *
           FROM
               (
                   SELECT
                           TSININ.INORNO           AS OrderNumber,
                           TSININ.INORDT           AS OrderDate,
                           TSININ.INIVDT           AS InvoiceDate,
                           TSINXN.XOTYP1           AS OrderTypePrimary,
                           TSINXN.XOTYP2           AS OrderTypeSecondary,
                           TSINXN.XOTYP3           AS OrderTypeUsrDefine3,
                           TSINXN.XOTYP4           AS OrderTypeUsrDefine4,
                           ROW_NUMBER() OVER (PARTITION BY
                                                  TSININ.INORNO,
                                                  TSININ.INORDT
                                              ORDER BY
                                                  TSININ.INIVDT DESC
                                             ) AS RowNumber
                   FROM
                           [$(Source_Data)]. [Wholesale_Invoicing_AFI].[TSININ] TSININ
                       JOIN
                           [$(Source_Data)].[Wholesale_Invoicing_AFI].[TSINXN] TSINXN
                               ON TSININ.ININVR = TSINXN.XNINVR
                                  AND TSININ.INORNO = TSINXN.XNORNO
               ) latest_inv
           WHERE
               RowNumber = 1),


        InvoiceDetail_Wrk
    AS (
           SELECT
               *
           FROM
               (
                   SELECT
                           TSININ.INORNO         AS OrderNumber,
                           TSININ.INORDT         AS OrderDate,
                           TSININ.INIVDT         AS InvoiceDate,
                           TSITXN.XTITNO         AS ItemNumber,
                           TSITXN.XTITSQ         AS ItemSequence,
                           TSITXN.XDSCNT         AS Discount,
                           TSITXN.XTCONF         AS PriceAdjustment,
                           TSITXN.XFRGHT         AS Freight,
                           TSITIN.ITPRIC         AS Price,
                           ROW_NUMBER() OVER (PARTITION BY
                                                  TSININ.INORNO,
                                                  TSININ.INORDT,
                                                  TSITXN.XTITNO ,
                                                  TSITXN.XTITSQ
                                              ORDER BY
                                                  TSININ.INIVDT DESC
                                             ) AS RowNumber
                    FROM
                           [$(Source_Data)]. [Wholesale_Invoicing_AFI].[TSININ] TSININ
                    JOIN
                           [$(Source_Data)]. [Wholesale_Invoicing_AFI].[TSITIN] TSITIN
                               ON TSININ.ININVR = TSITIN.ITINVR
                                  AND TSININ.INORNO = TSITIN.ITORNO
                    JOIN
                           [$(Source_Data)]. [Wholesale_Invoicing_AFI].[TSITXN] TSITXN
                               ON TSININ.ININVR = TSITXN.XTINVR
                                  AND TSININ.INORNO = TSITXN.XTORNO
                                  AND TSITIN.ITITNO = TSITXN.XTITNO
                                  AND TSITIN.ITITSQ = TSITXN.XTITSQ
               ) latest_inv
           WHERE
               RowNumber = 1),


         OpenOrderHeader_Wrk
    AS (   SELECT  DISTINCT
                   CODATAN.ORDNO  AS OrderNumber,
                   COMAST.ORDTE   AS OrderDate,
                   EXTORD.OTTYP1  AS OrderTypePrimary,
                   EXTORD.OTTYP2  AS OrderTypeSecondary,
                   EXTORD.OTTYP3  AS OrderTypeUsrDefine3,
                   EXTORD.OTTYP4  AS OrderTypeUsrDefine4
           FROM
                   [$(Source_Data)].[Wholesale_Codis_AFI].[codatan] CODATAN
               JOIN
                   [$(Source_Data)].[Wholesale_Codis_AFI].[COMAST] COMAST                        
                       ON (CODATAN.ORDNO = COMAST.ORDNO)
               JOIN
                   [$(Source_Data)].[Wholesale_Codis_AFI].[EXTORD]  EXTORD
                       ON (CODATAN.ORDNO = EXTORD.XORDNO)),

         OpenOrderDetail_Wrk
    AS (   SELECT
                   COMAST.ORDTE AS OrderDate,
                   COMAST.CUSNO AS CustomerNumber,
                   COMAST.SHPNO AS ShiptoNumber,
                   COMAST.ORDNO AS OrderNumber,
                   CODATAN.ITNBR AS ItemNumber,
                   CODATAN.ITMSQ AS ItemSequence,
                   CODATAN.COQTY AS OrderQuantity,
                   CODATAN.ISLPR AS Price,
                   EXTORIT.IFRGHT AS Freight,
                   EXTORIT.IHDFRT AS PriceAdjustment,
                   EXTORIT.IDSCNT AS Discount
           FROM
                   [$(Source_Data)].[Wholesale_Codis_AFI].[EXTORIT] EXTORIT
               JOIN
                   [$(Source_Data)].[Wholesale_Codis_AFI].[codatan] CODATAN
                       ON CODATAN.ORDNO = EXTORIT.[IORD]
                          AND CODATAN.ITMSQ = EXTORIT.[ISEQ]
               JOIN
                   [$(Source_Data)].[Wholesale_Codis_AFI].[COMAST] COMAST
                       ON EXTORIT.[IORD] = COMAST.ORDNO)
                       
    SELECT
            ORDAUDH.[OrderNo]                          AS OrderNo,
            CAST(CAST(ORDAUDH.CustomerNo AS INT) AS CHAR(8))                                                                 AS CustomerNumber,
            ORDAUDH.[ShipToNo]                                                                                             AS shiptoNumber,
            ORDAUDH.[WhseNo]                                                                                             AS Warehouse,
            CAST(CAST(CAST(ORDAUDH.OrderDate as INT) AS CHAR(8)) AS DATE)                                                   AS OrderDate,
            ORDAUDD.[ItemNo]                                                                                             AS ItemSKU,
            ORDAUDD.[ItemSequenceNo]                                                                                             AS ItemSequence,
            ORDAUDD.[Quantity]                                                                                             AS Quantity,
            COALESCE(ORDAUDD.[Quantity] * OpenOrderDetail.Price, ORDAUDD.[Quantity] * InvoiceDetail.Price, ORDAUDD.[NetAmount]) AS NetAmount,
            ORDAUDD.[ItemClass]                                                                                             AS ItemClass,
            CAST(CAST(CAST(ORDAUDD.RequestDate as INT) AS CHAR(8)) AS DATE)                                                   AS RequestDate,
            ORDAUDD.[ChangeTime]                                                                                             AS OrderChangeTime,
            CAST(CAST(CAST(ORDAUDD.ChangeDate as INT) AS CHAR(8)) AS DATE)                                                   AS OrderChangeDate,
            ORDAUDD.[QtyDecreaseReason]                                                                                             AS QuantityDescreaseReasonCode,
            COALESCE(OpenOrderDetail.Freight,         InvoiceDetail.Freight,         ORDAUDD.[Freight])                   AS Freight,
            COALESCE(OpenOrderDetail.PriceAdjustment, InvoiceDetail.PriceAdjustment, ORDAUDD.[Freight])                   AS PriceAdjustment,
            COALESCE(OpenOrderDetail.Discount,        InvoiceDetail.Discount,        ORDAUDD.[Dicount])                   AS Discount,
            ORDAUDH.[ArrivalMode]                                                                                             AS OrderArrivalMode,
            ORDAUDD.[UserIdChanging]                                                                                             AS ChangeByUser,
            ordaudd.[Packageid]                                                                                            AS Packageid,
            'USD'                                                                                                        AS CurrencyCode,
            ''                                                                                                           AS ItemStatus,
            COALESCE(OpenOrderHeader.OrderTypePrimary, InvoiceHeader.OrderTypePrimary, '')                               AS OrderTypePrimary,
            COALESCE(OpenOrderHeader.OrderTypeSecondary, InvoiceHeader.OrderTypeSecondary, '')                           AS OrderTypeSecondary,
            COALESCE(OpenOrderHeader.OrderTypeUsrDefine3, InvoiceHeader.OrderTypeUsrDefine3, '')                         AS OrderTypeUsrDefine3,
            COALESCE(OpenOrderHeader.OrderTypeUsrDefine4, InvoiceHeader.OrderTypeUsrDefine4, '')                         AS OrderTypeUsrDefine4
    FROM
            [$(Source_Data)].[Wholesale_SalesHistory_AFI].[ordaudh]      ORDAUDH
        JOIN
            [$(Source_Data)].[Wholesale_SalesHistory_AFI].[ordaudd]     ORDAUDD
                ON ORDAUDH.OrderTakenDate = ORDAUDD.OrderTakenDate
                   AND ORDAUDH.OrderNo = ORDAUDD.OrderNo

        LEFT JOIN
            InvoiceHeader_Wrk                                   InvoiceHeader
                ON InvoiceHeader.OrderNumber = ORDAUDH.[OrderNo]
                   AND InvoiceHeader.OrderDate  = ORDAUDH.OrderDate
        LEFT JOIN
           InvoiceDetail_Wrk                                    InvoiceDetail
                ON InvoiceDetail.OrderNumber = ORDAUDH.[OrderNo]
                   AND InvoiceDetail.ItemNumber = ORDAUDD.[ItemNo]
                   AND InvoiceDetail.ItemSequence = ORDAUDD.[ItemSequenceNo]
                   AND InvoiceDetail.OrderDate = ORDAUDH.OrderDate
        LEFT JOIN
            OpenOrderHeader_Wrk                                 OpenOrderHeader
                ON OpenOrderHeader.OrderNumber = ORDAUDH.[OrderNo]
                   AND OpenOrderHeader.OrderDate = ORDAUDH.OrderDate
        LEFT JOIN
            OpenOrderDetail_Wrk                                 OpenOrderDetail
                ON OpenOrderDetail.OrderNumber = ORDAUDH.[OrderNo]
                   AND OpenOrderDetail.ItemNumber = ORDAUDD.[ItemNo]
                   AND OpenOrderDetail.ItemSequence = ORDAUDD.[ItemSequenceNo]
                   AND OpenOrderDetail.OrderDate = ORDAUDH.OrderDate;

