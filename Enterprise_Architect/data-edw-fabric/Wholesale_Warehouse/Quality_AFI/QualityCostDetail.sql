CREATE TABLE [Quality_AFI].[QualityCostsDetail]
    (
        [Type]                CHAR(10)       NULL,
        [PONumber]            VARCHAR(22)    NULL,
        [InvoiceNumber]       DECIMAL(9)     NOT NULL,
        [OrderNumber]         VARCHAR(10)    NOT NULL,
        [CustomerNumber]      CHAR(8)        NULL,
        [ShiptoNumber]        CHAR(4)        NULL,
        [ItemSKU]             VARCHAR(15)    NOT NULL,
        [ItemSequence]        VARCHAR(7)     NOT NULL,
        [ItemClass]           CHAR(4)        NULL,
        [ItemStatus]          CHAR(1)        NULL,
        [Period]              SMALLINT       NULL,
        [Year]                SMALLINT       NULL,
        [SalesCategory]       CHAR(3)        NULL,
        [ImportDomestic]      CHAR(1)        NULL,
        [Division]            CHAR(1)        NULL,
        [FinancialDivision]   CHAR(1)        NULL,
        [Warehouse]           CHAR(3)        NULL,
        [Businesstype]        CHAR(2)        NULL,
        [CreditCode]          CHAR(4)        NULL,
        [QualityCode]         CHAR(4)        NULL,
        [DefectCode]          CHAR(2)        NULL,
        [LocationCode]        CHAR(2)        NULL,
        [ReturnAuthcode]      CHAR(3)        NULL,
        [Percent]             INT            NOT NULL,
        [QualityCredQnty]     INT            NOT NULL,
        [QualityCredits]      DECIMAL(12, 2) NOT NULL, --Money
        [ReturnQnty]          INT            NOT NULL,
        [Returns]             DECIMAL(12, 2) NOT NULL, --Money
        [ShortShipQnty]       INT            NOT NULL,
        [ShortShips]          DECIMAL(12, 2) NOT NULL, --Money
        [Freight]             DECIMAL(12, 2) NOT NULL, -- Money
        [Discount]            DECIMAL(12, 2) NOT NULL, --Money
        [Adjust]              DECIMAL(12, 2) NOT NULL, --Money
        [SerialNumber]        VARCHAR(15)    NULL,
        [PNumber]             VARCHAR(15)    NULL,
        [OrgSequenceNumber]   DECIMAL(7)     NULL,
        [TripNumber]          DECIMAL(7)     NULL,
        [DropNumber]          DECIMAL(2)     NULL,
        [OrgInvoiceNumber]    DECIMAL(9)     NULL,
        [OrgOrderNumber]      VARCHAR(10)    NULL,
        [OrderDate]           DATE           NULL,     --Datetime
        [OrderMode]           CHAR(2)        NULL,
        [AddUser]             VARCHAR(10)    NULL,
        [Carrier]             VARCHAR(25)    NULL,
        [TruckNumber]         VARCHAR(15)    NULL,
        [DeliveryDate]        DATE           NULL,     --Datetime
        [ScanName]            VARCHAR(10)    NULL,
        [LoadDate]            DATE           NULL,     -- Datetime
        [OrderType]           CHAR(1)        NULL,
        [TransactionDate]     DATE           NOT NULL, -- Datetime
        [VendorNumber]        CHAR(8)        NULL,
        [WhereMade]           VARCHAR(15)    NULL,
        [ManufactureDate]     DATE           NULL,     -- Datetime
        [UserGroup]           VARCHAR(12)    NULL,
        [custservrep]         CHAR(5)        NULL,
        [Week]                SMALLINT       NULL,
        [Territory]           CHAR(5)        NULL,
        [Country]             CHAR(3)        NULL,
        [State]               CHAR(2)        NULL,
        [MsaFips]             CHAR(5)        NULL,
        [Price]               DECIMAL(8, 2)  NOT NULL,  --  CONSTRAINT [DF_QualityCostsDetail_Price]           DEFAULT ((0)) NOT NULL,
        [SalesNumber]         CHAR(5)        NOT NULL,     --   CONSTRAINT [DF_QualityCostsDetail_SalesNumber]         DEFAULT ('') NOT NULL,
        [ItemType]            CHAR(2)        NOT NULL,      --  CONSTRAINT [DF_QualityCostsDetail_ItemType]            DEFAULT ('') NOT NULL,
        [InvoiceNumber2]      VARCHAR(9)     NOT NULL,   ---  CONSTRAINT [DF_QualityCostsDetail_InvoiceNumber2]  DEFAULT ('') NOT NULL,
        [NetSalesAmount]      DECIMAL(13, 2) NOT NULL, -- CONSTRAINT [DF_QualityCostsDetail_NetSalesAmount] DEFAULT ((0)) NOT NULL,
        [Scrap]               CHAR(4)        NULL,
        [Quantity]            DECIMAL(8, 3)  NOT NULL, -- CONSTRAINT [DF_QualityCostsDetail_Quantity] DEFAULT ((0)) ,
        [QualityCategory]     VARCHAR(20)    NULL,
        [CSDefectControlCode] CHAR(1)        NULL,
        [OrgInvoiceDate]      DATE           NULL,     --Datetime
        [EnterDate]           CHAR(8)        NULL,
        [AprvDny]             CHAR(1)        NULL
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Year]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Year]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_WhereMade]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [WhereMade]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Week]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Week]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Warehouse]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_UserGroup]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [UserGroup]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Type]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Type]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_TruckNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [TruckNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_TripNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [TripNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Territory]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Territory]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_State]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [State]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ShiptoNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ShiptoNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_SerialNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [SerialNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Scrap]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Scrap]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_SalesNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [SalesNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_SalesCategory]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [SalesCategory]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ReturnAuthcode]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ReturnAuthcode]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Quantity]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Quantity]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_QualityCredQnty]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [QualityCredQnty]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_QualityCredits]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [QualityCredits]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_QualityCode]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [QualityCode]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_QualityCategory]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [QualityCategory]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Period]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Period]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Percent]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Percent]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrgSequenceNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrgSequenceNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrgOrderNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrgOrderNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrgInvoiceNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrgInvoiceNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrgInvoiceDate]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrgInvoiceDate]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrderType]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrderType]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrderNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrderNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrderMode]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrderMode]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_OrderDate]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [OrderDate]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_NetSalesAmount]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [NetSalesAmount]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_MsaFips]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [MsaFips]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ManufactureDate]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ManufactureDate]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_LocationCode]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [LocationCode]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_LoadDate]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [LoadDate]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ItemType]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ItemType]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ItemStatus]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ItemStatus]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ItemSequence]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ItemSequence]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ItemSKU]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ItemClass]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ItemClass]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_InvoiceNumber2]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [InvoiceNumber2]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_InvoiceNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [InvoiceNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ImportDomestic]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ImportDomestic]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_FinancialDivision]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [FinancialDivision]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_EnterDate]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [EnterDate]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_TransactionDate]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [TransactionDate]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_DropNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [DropNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Division]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Division]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Discount]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Discount]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_DeliveryDate]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [DeliveryDate]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_DefectCode]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [DefectCode]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_custservrep]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [custservrep]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_CSDefectControlCode]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [CSDefectControlCode]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_CreditCode]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [CreditCode]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Country]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Country]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Carrier]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Carrier]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Businesstype]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Businesstype]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_AddUser]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [AddUser]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_CustomerNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [CustomerNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ShortShips]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ShortShips]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ShortShipQnty]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ShortShipQnty]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ScanName]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ScanName]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Returns]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Returns]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_ReturnQnty]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [ReturnQnty]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Price]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Price]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_PONumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [PONumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_PNumber]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [PNumber]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Freight]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Freight]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_AprvDny]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [AprvDny]
    );


GO
CREATE STATISTICS [Stat_QualityCostsDetail_Adjust]
    ON [Quality_AFI].[QualityCostsDetail]
    (
        [Adjust]
    );


