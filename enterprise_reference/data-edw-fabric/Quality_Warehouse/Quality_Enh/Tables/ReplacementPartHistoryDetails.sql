CREATE TABLE [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Order Number]              INT          NOT NULL,
        [RP Entered Date]              DATE         NULL,
        [Ship Date]                    DATE         NULL,
        [RP Entry Person]              VARCHAR(10)  NULL,
        [RP Customer PO Number]        VARCHAR(22)  NULL,
        [RP Charge Type]               CHAR(1)      NULL,
        [RP Ship Via]                  CHAR(3)      NULL,
        [RP Shipping Method]           CHAR(1)      NULL,
        [RP Service Type]              VARCHAR(22)  NULL,
        [RP Order Type]                CHAR(1)      NULL,
        [RP Ship To Name]              VARCHAR(25)  NULL,
        [RP Ship To Address 1]         VARCHAR(25)  NULL,
        [RP Ship To Address 2]         VARCHAR(25)  NULL,
        [RP Ship To Address 3]         VARCHAR(25)  NULL,
        [RP Ship To City]              VARCHAR(25)  NULL,
        [RP Ship To State]             CHAR(2)      NULL,
        [RP Ship To Zip Code]          CHAR(5)      NULL,
        [RP Ship To Country]           VARCHAR(25)  NULL,
        [Orig Invoice Number Entered]  DECIMAL(9)   NULL,
        [Orig Order Number Entered]    VARCHAR(10)  NULL,
        [Orig Serial Number Entered]   VARCHAR(15)  NULL,
        [No Serial Reason]             CHAR(1)      NOT NULL,
        [Orig Invoice Date for Serial] DATE         NULL
    );

GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_Ship_Date]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [Ship Date]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Shipping_Method]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Shipping Method]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Ship_Via]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Ship Via]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Ship_To_Zip_Code]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Ship To Zip Code]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Ship_To_State]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Ship To State]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Ship_To_Country]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Ship To Country]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Service_Type]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Service Type]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Order_Type]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Order Type]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Order_Number]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Order Number]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Charge_Type]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Charge Type]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_No_Serial_Reason]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [No Serial Reason]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_RP_Entered_Date]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [RP Entered Date]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_Orig_Invoice_Number_Entered]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [Orig Invoice Number Entered]
    );


GO
CREATE STATISTICS [Stat_ReplacementPartHistoryDetails_Orig_Invoice_Date_for_Serial]
    ON [Quality_Enh].[ReplacementPartHistoryDetails]
    (
        [Orig Invoice Date for Serial]
    );

