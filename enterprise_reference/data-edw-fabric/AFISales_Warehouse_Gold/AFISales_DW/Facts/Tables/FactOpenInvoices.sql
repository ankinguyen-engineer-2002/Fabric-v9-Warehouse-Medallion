CREATE TABLE [AFISales_DW].[FactOpenInvoices] (
    [RowID]                        BIGINT          NOT NULL, --IDENTITY (1, 1) 
    [Account And Shipto Number]    CHAR (13)       NULL,
    [Shipped History Invoice Date] DATE            NULL,
    [Invoice Date]                 DATE            NULL,
    [Invoice Number]               INT             NULL,
    [Invoice Amount]               DECIMAL (12, 2) NULL,
    [Paid Amount]                  DECIMAL (12, 2) NULL,
    [Open Amount]                  DECIMAL (12, 2) NULL
)

GO
CREATE STATISTICS [Stat_FactOpenInvoices_InvoiceDate]
    ON [AFISales_DW].[FactOpenInvoices]([Invoice Date]);


GO
CREATE STATISTICS [Stat_FactOpenInvoices_Shipped_History_Invoice_Date]
    ON [AFISales_DW].[FactOpenInvoices]([Shipped History Invoice Date]);


GO
CREATE STATISTICS [Stat_FactOpenInvoices_Open_Amount]
    ON [AFISales_DW].[FactOpenInvoices]([Open Amount]);


GO
CREATE STATISTICS [Stat_FactOpenInvoices_Invoice_Number]
    ON [AFISales_DW].[FactOpenInvoices]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactOpenInvoices_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactOpenInvoices]([Account And Shipto Number]);

