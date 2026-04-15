CREATE VIEW [AFISales_DW_Wrk].[v_FactOpenInvoices]
AS
    SELECT
            ROW_NUMBER() OVER(ORDER BY OpenInvoices.CustomerNumber)    AS RowID,
            CASE
                WHEN ISNULL(InvoiceHeader.ShiptoNumber, '') = ''
                    THEN
                    OpenInvoices.CustomerNumber
                ELSE
                    RTRIM(OpenInvoices.CustomerNumber) + '-' + LTRIM(InvoiceHeader.[ShiptoNumber])
            END                                                     AS [Account And Shipto Number],
            ISNULL(InvoiceHeader.InvoiceDate, '1900-01-01')         AS [Shipped History Invoice Date],
            ISNULL(OpenInvoices.InvoiceDate, '1900-01-01')          AS [Invoice Date],
            CASE  
                WHEN ISNUMERIC(OpenInvoices.InvoiceNumber) = 1
                     AND OpenInvoices.InvoiceNumber NOT LIKE '%[$+-\.]%'
                    THEN
                    OpenInvoices.InvoiceNumber
                ELSE
                    0
            END                                 AS [Invoice Number],
            OpenInvoices.InvoiceAmount          AS [Invoice Amount],
            OpenInvoices.TotalCredit            AS [Paid Amount],
            OpenInvoices.OpenAmount             AS [Open Amount]
    FROM
            [$(Wholesale_Warehouse)].SalesHistory_AFI.OpenInvoices
          LEFT JOIN
            [$(Wholesale_Warehouse)].SalesHistory_AFI.InvoiceHeader
                ON CAST(OpenInvoices.InvoiceNumber AS VARCHAR(9)) = InvoiceHeader.[InvoiceNumber] 
                   AND ISNULL(OpenInvoices.InvoiceDate, '1900-01-01')
                   BETWEEN DATEADD(DAY, -2, InvoiceHeader.[InvoiceDate]) AND DATEADD(DAY, 2, InvoiceHeader.[InvoiceDate])
                   AND OpenInvoices.CustomerNumber = InvoiceHeader.[CustomerNumber]
                   AND OpenInvoices.InvoiceType <> 3
                   AND OpenInvoices.OpenAmount <> 0;
