CREATE TABLE [AFISales_DW].[FactSpecialCharges] (
    [RowID]                      BIGINT          NOT NULL, --IDENTITY (1, 1)
    [Invoice Date]               DATE            NULL,
    [Invoice Number]             DECIMAL (9)     NOT NULL,
    [Sequence Number]            DECIMAL (3)     NULL,
    [Warehouse]                  CHAR (3)        NULL,
    [Account And Shipto Number]  CHAR (13)       NULL,
    [Territory]                  CHAR (10)       NULL,
    [Shipto AddressID]           INT             NULL,
    [Billto AddressID]           INT             NULL,
    [Credit Code]                CHAR (3)        NULL,
    [Charge Amount]              DECIMAL (11, 3) NULL,
    [Credit Code Description]    VARCHAR (30)    NOT NULL,
    [Credit ID Code]             CHAR (1)        NOT NULL,
    [Finance Code]               CHAR (3)        NULL,
    [Apply To Commission]        CHAR (1)        NULL,
    [Accrual Credit]             CHAR (1)        NULL,
    [Special Charge Code]        CHAR (1)        NULL,
    [Sales Tax Flag]             CHAR (1)        NULL,
    [Type Code]                  VARCHAR (10)    NULL,
    [Allocation Code]            VARCHAR (10)    NULL,
    [Commission Adjustment Flag] CHAR (1)        NULL
)
GO

CREATE STATISTICS [Stat_FactSpecialCharges_Warehouse]
    ON [AFISales_DW].[FactSpecialCharges]([Warehouse]);


GO
CREATE STATISTICS [Stat_FactSpecialCharges_Territory]
    ON [AFISales_DW].[FactSpecialCharges]([Territory]);


GO
CREATE STATISTICS [Stat_FactSpecialCharges_Shipto_AddressID]
    ON [AFISales_DW].[FactSpecialCharges]([Shipto AddressID]);


GO
CREATE STATISTICS [Stat_FactSpecialCharges_Invoice_Number]
    ON [AFISales_DW].[FactSpecialCharges]([Invoice Number]);


GO
CREATE STATISTICS [Stat_FactSpecialCharges_Invoice_Date]
    ON [AFISales_DW].[FactSpecialCharges]([Invoice Date]);


GO
CREATE STATISTICS [Stat_FactSpecialCharges_Credit_Code]
    ON [AFISales_DW].[FactSpecialCharges]([Credit Code]);


GO
CREATE STATISTICS [Stat_FactSpecialCharges_Billto_AddressID]
    ON [AFISales_DW].[FactSpecialCharges]([Billto AddressID]);


GO
CREATE STATISTICS [Stat_FactSpecialCharges_Account_And_Shipto_Number]
    ON [AFISales_DW].[FactSpecialCharges]([Account And Shipto Number]);

