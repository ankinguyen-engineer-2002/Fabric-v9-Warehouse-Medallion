CREATE VIEW [SSAS_AFISALES_OLAP].[DimInvoiceHeader]
AS
    SELECT
        [Invoice Date],
        [Invoice Number],
        [Order Number],
        [Trip Number],
        LEFT([Purchase Order], 22) AS [Purchase Order],
        [Order Arrival Mode],
        [Primary Order Type],
        [Secondary Order Type],
        [Order Arrival Group],
        [Order Arrival Electronic],
        [3rd Order Type],
        [4th Order Type],
        [Invoice Credit Code],
        [Order Sequence],
        [Request Date],
        [Promise Date],
        [Delivery Date],
        [Original Invoice Number],
        [Original Invoice Date],
        [Original Delivery Method]
    FROM
        AFISales_DW.DimInvoiceHeader
    UNION ALL

    --- add in generic 'zero' invoice numbers for quality credits without original invoice numbers
    SELECT
            [Invoice Date]             = CAST(d.[Transaction Date] AS DATE),
            [Invoice Number]           = 0,
            [Order Number]             = 'N/A',
            [Trip Number]              = 0,
            [Purchase Order]           = 'N/A',
            [Order Arrival Mode]       = NULL,
            [Primary Order Type]       = NULL,
            [Secondary Order Type]     = NULL,
            [Order Arrival Group]      = NULL,
            [Order Arrival Electronic] = NULL,
            [3rd Order Type]           = NULL,
            [4th Order Type]           = NULL,
            [Invoice Credit Code]      = NULL,
            [Order Sequence]           = NULL,
            [Request Date]             = NULL,
            [Promise Date]             = NULL,
            [Delivery Date]            = NULL,
            [Original Invoice Number]  = NULL,
            [Original Invoice Date]    = NULL,
            [Original Delivery Method] = NULL
    FROM
            AFISales_DW.DimDateFile d --- was MasterData_DW
    WHERE
            d.[Transaction Date]
    BETWEEN DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), -2567) AND DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 7)
    UNION ALL

    ---- add in credit memos that were not run through the shipped history process
    SELECT
            FactOpenInvoices.[Invoice Date],
            FactOpenInvoices.[Invoice Number],
            [Order Number]             = 'N/A',
            [Trip Number]              = 0,
            [Purchase Order]           = 'N/A',
            [Order Arrival Mode]       = NULL,
            [Primary Order Type]       = NULL,
            [Secondary Order Type]     = NULL,
            [Order Arrival Group]      = NULL,
            [Order Arrival Electronic] = NULL,
            [3rd Order Type]           = NULL,
            [4th Order Type]           = NULL,
            [Invoice Credit Code]      = NULL,
            [Order Sequence]           = NULL,
            [Request Date]             = NULL,
            [Promise Date]             = NULL,
            [Delivery Date]            = NULL,
            [Original Invoice Number]  = NULL,
            [Original Invoice Date]    = NULL,
            [Original Delivery Method] = NULL
    FROM
            AFISales_DW.FactOpenInvoices
        LEFT JOIN
            AFISales_DW.DimInvoiceHeader
                ON AFISales_DW.DimInvoiceHeader.[Invoice Date] = AFISales_DW.FactOpenInvoices.[Invoice Date]
                   AND AFISales_DW.DimInvoiceHeader.[Invoice Number] = AFISales_DW.FactOpenInvoices.[Invoice Number]
    WHERE
            AFISales_DW.DimInvoiceHeader.[Invoice Number] IS NULL;