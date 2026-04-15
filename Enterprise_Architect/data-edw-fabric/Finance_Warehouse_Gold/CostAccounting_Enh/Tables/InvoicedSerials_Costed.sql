CREATE TABLE [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Data_Source]                        VARCHAR(50)    NULL,
        [Date_Received_Inventory]            DATE           NULL,
        [FiscalYear_Inventory]               INT            NULL,
        [FiscalWeekEnding_Inventory]         DATE           NULL,
        [FiscalPeriodName_Inventory]         DATE           NULL,
        [FiscalPeriod_Inventory]             INT            NULL,
        [FiscalMonthEnding_Inventory]        DATE           NULL,
        [DateInvoiced]                       DATE           NULL,
        [FiscalYearInvoice]                  INT            NULL,
        [FiscalWeekEndingInvoice]            DATE           NULL,
        [FiscalPeriodNameInvoice]            VARCHAR(100)   NULL,
        [FiscalPeriodInvoice]                INT            NULL,
        [FiscalMonthEndingInvoice]           DATE           NULL,
        [InvoiceNumber]                      INT            NULL,
        [OrderNumber]                        VARCHAR(20)    NULL,
        [TripNumber]                         INT            NULL,
        [ItemNumber]                         VARCHAR(20)    NULL,
        [ItemDescription]                    VARCHAR(500)   NULL,
        [AFIFinanceDivision]                 VARCHAR(50)    NULL,
        [ItemGrouping]                       VARCHAR(50)    NULL,
        [SerialNumber]                       VARCHAR(20)    NULL,
        [ItemSeqNumber]                      INT            NULL,
        [CustomerNumber]                     INT            NULL,
        [ShiptoNumber]                       CHAR(5)        NULL,
        [Account And Shipto Number]          VARCHAR(20)    NULL,
        [Customer Name]                      VARCHAR(100)   NULL,
        [Soldto_State]                       VARCHAR(25)    NULL,
        [Soldto_StateCode]                   CHAR(5)        NULL,
        [Soldto_Country]                     VARCHAR(25)    NULL,
        [Soldto_CountryCode]                 CHAR(5)        NULL,
        [ShipFrom_Warehouse]                 CHAR(5)        NULL,
        [MFG_City]                           VARCHAR(50)    NULL,
        [MFG_StateCode]                      VARCHAR(10)    NULL,
        [MFG_CountryCode]                    CHAR(5)        NULL,
        [MFG_Country]                        VARCHAR(50)    NULL,
        [Flag_AshleyFacility]                VARCHAR(50)    NULL,
        [PricePerUnit]                       DECIMAL(6, 2)  NULL,
        [InvoiceAmount]                      DECIMAL(10, 4) NULL,
        [Total_Allow_$PerUnit]               DECIMAL(16, 8) NULL,
        [Total_Returns_$PerUnit]             DECIMAL(16, 8) NULL,
        [Ext_Gross Amount Shipped]           DECIMAL(16, 8) NULL,
        [Ext_Gross Quantity Shipped]         DECIMAL(16, 8) NULL,
        [Ext_Net Quantity Shipped]           DECIMAL(16, 8) NULL,
        [Ext_Net Amount Shipped]             DECIMAL(16, 8) NULL,
        [Ext_Total Discounts]                DECIMAL(16, 8) NULL,
        [ExtInvoiceTax Amount]               DECIMAL(16, 8) NULL,
        [Ext_Special Charge Amount]          DECIMAL(16, 8) NULL,
        [Ext_Spec_Charge_Amount_Updated]     DECIMAL(16, 8) NULL,
        [Ext_Charge_Fuel]                    DECIMAL(16, 8) NULL,
        [Ext_Total_Freight]                  DECIMAL(16, 8) NULL,
        [PU_Gross Amount Shipped]            DECIMAL(16, 8) NULL,
        [PU_Net Amount Shipped]              DECIMAL(16, 8) NULL,
        [PU_Total Discounts]                 DECIMAL(16, 8) NULL,
        [PUInvoiceTax Amount]                DECIMAL(16, 8) NULL,
        [PU_Special Charge Amount]           DECIMAL(16, 8) NULL,
        [PU_Spec_Charge_Amount_Updated]      DECIMAL(16, 8) NULL,
        [PU_Charge_Fuel]                     DECIMAL(16, 8) NULL,
        [PU_Total_Freight]                   DECIMAL(16, 8) NULL,
        [Division]                           VARCHAR(10)    NULL,
        [AFI_Cubes]                          DECIMAL(16, 8) NULL,
        [WNK_Cubes]                          DECIMAL(16, 8) NULL,
        [MIL_Cubes]                          DECIMAL(16, 8) NULL,
        [Rate_HCM]                           INT            NULL,
        [Rate_DNG]                           INT            NULL,
        [Imp_Freight_Item]                   DECIMAL(16, 8) NULL,
        [Imp_Duty]                           DECIMAL(16, 8) NULL,
        [COGS]                               DECIMAL(16, 8) NULL,
        [QTY_Shipped]                        INT            NULL,
        [Cost_Xfer]                          INT            NULL,
        [Transfer_Source]                    VARCHAR(25)    NULL,
        [Transfer_Destination]               VARCHAR(25)    NULL,
        [Cost_Xfer_NonShuttle]               INT            NULL,
        [Cost_Xfer_Shuttle]                  INT            NULL,
        [Variance_Perc_Labor]                DECIMAL(16, 8) NULL,
        [Variance_Perc_Material]             DECIMAL(16, 8) NULL,
        [Variance_Perc_Overhead]             DECIMAL(16, 8) NULL,
        [Special Freight]                    DECIMAL(16, 8) NULL,
        [Special Charges]                    DECIMAL(16, 8) NULL,
        [Direct_Labor]                       DECIMAL(16, 8) NULL,
        [Overhead]                           DECIMAL(16, 8) NULL,
        [Material]                           DECIMAL(16, 8) NULL,
        [Freight Cost]                       DECIMAL(16, 8) NULL,
        [Markup]                             DECIMAL(16, 8) NULL,
        [Markup_Backout]                     DECIMAL(16, 8) NULL,
        [ItemClass]                              VARCHAR(10)    NULL,
        [Series]                             VARCHAR(10)    NULL,
        [Inventory_Nature]                   INT            NULL,
        [MaterialCost_Whse335_Acct(3824800)] DECIMAL(16, 8) NULL
    );



GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_ShipFrom_Warehouse]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [ShipFrom_Warehouse]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Series]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Series]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_QTY_Shipped]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [QTY_Shipped]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_PU_Net_Amount_Shipped]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [PU_Net Amount Shipped]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Overhead]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Overhead]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_OrderNumber]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [OrderNumber]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Material]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Material]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Markup_Backout]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Markup_Backout]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Markup]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Markup]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_ItemNumber]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [ItemNumber]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_ItemClass]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [ItemClass]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_InvoiceNumber]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [InvoiceNumber]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Inventory_Nature]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Inventory_Nature]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Freight_Cost]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Freight Cost]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Flag_AshleyFacility]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Flag_AshleyFacility]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_FiscalWeekEndingInvoice]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [FiscalWeekEndingInvoice]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_FiscalPeriodNameInvoice]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [FiscalPeriodNameInvoice]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Division]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Division]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_Direct_Labor]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [Direct_Labor]
    );


GO
CREATE STATISTICS [Stat_InvoicedSerials_Costed_DateInvoiced]
    ON [CostAccounting_Enh].[InvoicedSerials_Costed]
    (
        [DateInvoiced]
    );

