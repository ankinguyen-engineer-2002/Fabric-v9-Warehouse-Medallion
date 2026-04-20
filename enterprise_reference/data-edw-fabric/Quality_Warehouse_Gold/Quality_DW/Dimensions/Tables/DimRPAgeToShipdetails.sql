CREATE TABLE [Quality_DW].[DimRPAgeToShipdetails]
    (
        [RowNumber]            BIGINT         NOT NULL, -- IDENTITY (1, 1) 
        [Item Seq]             DECIMAL(2)     NOT NULL,
        [RP Key]               INT            NOT NULL,
        [Acct#]                CHAR(8)        NULL,
        [Country]              CHAR(3)        NOT NULL,
        [User]                 VARCHAR(10)    NULL,
        [Entry Date]           VARCHAR(10)    NULL,
        [Item #]               VARCHAR(15)    NULL,
        [Item Status]          CHAR(1)        NULL,
        [Serial #]             VARCHAR(15)    NULL,
        [SR #]                 VARCHAR(22)    NULL,
        [RP #]                 VARCHAR(15)    NULL,
        [RP Desc]              CHAR(30)       NULL,
        [Order Qty]            DECIMAL(4)     NULL,
        [Charge Type]          VARCHAR(12)    NULL,
        [Ship Via]             CHAR(3)        NULL,
        [Part Picked Date]     VARCHAR(10)    NULL,
        [Order Packed Date]    VARCHAR(10)    NULL,
        [Ship Date]            VARCHAR(10)    NULL,
        [Age to Pick]          INT            NULL,
        [Age to Pack]          INT            NULL,
        [Age to Ship]          INT            NULL,
        [Ship Cost]            DECIMAL(6, 2)  NULL,
        [Weekending Open]      VARCHAR(10)    NULL,
        [Weekending Close]     VARCHAR(10)    NULL,
        [Finance Division]     VARCHAR(19)    NULL,
        [Src Whse]             CHAR(3)        NULL,
        [Src Whse Qty]         DECIMAL(38, 3) NULL,
        [Oth Whses Qty]        DECIMAL(38, 3) NULL,
        [In-Transit Qty]       DECIMAL(38, 3) NULL,
        [On-Order Qty]         DECIMAL(38, 3) NULL,
        [Last PO Rcvd Date]    CHAR(10)       NULL,
        [Next PO Due Date]     CHAR(10)       NULL,
        [Last MFG Date]        CHAR(10)       NULL,
        [Last Mfg Work Center] CHAR(5)        NULL,
        [Next Mfg Date]        CHAR(10)       NULL
    );

GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Src_Whse]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Src Whse]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_RP_KEY]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [RP Key]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Last_MFG_Date]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Last MFG Date]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Item_Seq]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Item Seq]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Acct#]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Acct#]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Weekending_Open]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Weekending Open]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Weekending_Close]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Weekending Close]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Ship_Date]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Ship Date]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Serial_#]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Serial #]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Part_Picked_Date]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Part Picked Date]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Order_Packed_Date]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Order Packed Date]
    );


GO
CREATE STATISTICS [Stat_DimRPAgeToShipdetails_Entry_Date]
    ON [Quality_DW].[DimRPAgeToShipdetails]
    (
        [Entry Date]
    );

