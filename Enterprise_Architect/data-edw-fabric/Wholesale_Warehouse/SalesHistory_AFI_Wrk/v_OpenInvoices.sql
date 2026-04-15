CREATE VIEW [SalesHistory_AFI_Wrk].[v_OpenInvoices]
AS
    SELECT
            CAST([CUSNO] AS CHAR(8))        AS [CustomerNumber],
            [PONUM]                         AS [PurchaseOrder],
            [INVNO]                         AS [InvoiceNumber],
            CAST([INVAM] AS DECIMAL(12, 2)) AS [InvoiceAmount],
            CAST([OPAMT] AS DECIMAL(12, 2)) AS [OpenAmount],
            CASE WHEN CAST([TRNDT] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([TRNDT] as INT) AS CHAR(8)) AS DATE) END AS [DateLastPayment],
            CASE WHEN CAST([AGEDT] as INT) = 0 THEN NULL ELSE CAST(CAST(CAST([AGEDT] as INT) AS CHAR(8)) AS DATE) END AS [InvoiceDate],
            CAST([CATCD] AS CHAR(6))        AS [CategoryCode],
            CAST([CURCD] AS CHAR(3))        AS [CurrencyCode],
            CAST([CUSINVTP] AS INT)         AS [InvoiceType],
            [CRMNR]                         AS [CreditMemoNumber],
            CAST([TTLCR] AS DECIMAL(12, 2)) AS [TotalCredit]
    FROM
     (
        SELECT
            Invoices.*,
            CASE
                WHEN OPAMT < 0
                    OR INVAM < 0
                    THEN
                    INVNO
                ELSE
                    '0'
            END           AS CRMNR,
            INVAM - OPAMT AS TTLCR
        FROM
            (
                SELECT
                        CAST(CAST(CusCusnbr AS INT) AS CHAR(8)) AS CUSNO,
                        TheirReference                     AS PONUM,
                        CAST(CusInvifm  AS INT)    AS INVNO,
                        SUM(TransactionValuePersonalLedger / 100)          AS INVAM,
                        SUM(TransactionBalanceSettlement / 100)          AS OPAMT,
                        EffectiveDate + 19000000          AS TRNDT,
                        DateofDocument + 19000000          AS AGEDT,
                        CASE
                            WHEN LEFT(CusInvtyp, 1) = '0'
                                THEN
                                RIGHT(CusInvtyp, 1)
                            ELSE
                                CusInvtyp
                        END                        AS CATCD,
                        'USD'                      AS CURCD,
                        CAST(CusInvtyp AS INT)     AS CUSINVTP
                FROM
                        [$(Source_Data)].[Wholesale_Invoicing_AFI].[MC2CUIL4I]
                    LEFT OUTER JOIN
                        [$(Source_Data)].[Wholesale_Codis_AFI].[YAARREP]
                            ON CusCusnbr = TransactionID
                WHERE
                        EffectiveDate IS NOT NULL
                        AND CusOutbal <> 0
                        AND LEFT(CusEntity, 1) <> 'V'
                        AND CusInvifm NOT LIKE '%CASH%'
                        AND CusInvifm NOT LIKE 'UNC%'
                GROUP BY
                        CusCusnbr,
                        CusInvifm,
                        CusInvtyp,
                        EffectiveDate,
                        DateofDocument,
                        TheirReference
            ) Invoices
            )  InvData
GO
