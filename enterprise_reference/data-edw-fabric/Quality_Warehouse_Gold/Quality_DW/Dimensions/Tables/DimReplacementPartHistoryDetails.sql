CREATE TABLE [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [RowNumber]                    BIGINT      NOT NULL, --IDENTITY (1, 1)
        [RP Order Number]              INT         NOT NULL,
        [RP Entered Date]              DATE        NULL,
        [RP Entry Person]              VARCHAR(10) NULL,
        [RP Customer PO Number]        VARCHAR(22) NULL,
        [RP Charge Type]               CHAR(1)     NULL,
        [RP Ship Via]                  CHAR(3)     NULL,
        [RP Shipping Method]           CHAR(1)     NULL,
        [RP Service Type]              VARCHAR(22) NULL,
        [RP Order Type]                CHAR(1)     NULL,
        [RP Ship To Name]              VARCHAR(25) NULL,
        [RP Ship To Address 1]         VARCHAR(25) NULL,
        [RP Ship To Address 2]         VARCHAR(25) NULL,
        [RP Ship To Address 3]         VARCHAR(25) NULL,
        [RP Ship To City]              VARCHAR(25) NULL,
        [RP Ship To State]             CHAR(2)     NULL,
        [RP Ship To Zip Code]          CHAR(5)     NULL,
        [RP Ship To Country]           VARCHAR(25) NULL,
        [Orig Invoice Number Entered]  DECIMAL(9)  NULL,
        [Orig Order Number Entered]    VARCHAR(10) NULL,
        [Orig Serial Number Entered]   VARCHAR(15) NULL,
        [No Serial Reason]             CHAR(1)     NOT NULL,
        [Orig Invoice Date for Serial] DATE        NULL
    );

GO
CREATE STATISTICS [Stat_DimReplacementPartHistoryDetails_RP_Order_Number]
    ON [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [RP Order Number]
    );


GO
CREATE STATISTICS [Stat_DimReplacementPartHistoryDetails_Orig_Serial_Number_Entered]
    ON [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [Orig Serial Number Entered]
    );


GO
CREATE STATISTICS [Stat_DimReplacementPartHistoryDetails_RP_Ship_To_Country]
    ON [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [RP Ship To Country]
    );


GO
CREATE STATISTICS [Stat_DimReplacementPartHistoryDetails_RP_Ship_To_Address_3]
    ON [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [RP Ship To Address 3]
    );


GO
CREATE STATISTICS [Stat_DimReplacementPartHistoryDetails_RP_Ship_To_Address_2]
    ON [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [RP Ship To Address 2]
    );


GO
CREATE STATISTICS [Stat_DimReplacementPartHistoryDetails_RP_Service_Type]
    ON [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [RP Service Type]
    );


GO
CREATE STATISTICS [Stat_DimReplacementPartHistoryDetails_RP_Entry_Person]
    ON [Quality_DW].[DimReplacementPartHistoryDetails]
    (
        [RP Entry Person]
    );

