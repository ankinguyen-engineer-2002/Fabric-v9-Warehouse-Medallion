CREATE VIEW [SSAS_AFISALES_OLAP].[FactOpenInvoices]
AS
    SELECT
        [Account And Shipto Number],
        CASE
            WHEN [Shipped History Invoice Date] = '1900-01-01'
                THEN
                [Invoice Date]
            ELSE
                [Shipped History Invoice Date]
        END                        AS [Invoice Date],
        [Invoice Number],
        [Invoice Amount],
        [Paid Amount],
        [Open Amount]
    FROM
        AFISales_DW.FactOpenInvoices
    WHERE
        [Open Amount] <> 0;