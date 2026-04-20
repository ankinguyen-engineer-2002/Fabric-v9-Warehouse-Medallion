CREATE TABLE [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [OrderNumber]                CHAR(7)        NULL,
        [ItemSKU]                    VARCHAR(15)    NULL,
        [Warehouse]                  CHAR(3)        NULL,
        [ItemSequence]               DECIMAL(7, 0)  NULL,
        [QuantiyOrdered]             DECIMAL(10, 3) NULL,
        [QuantityShipped]            DECIMAL(10, 3) NULL,
        [QuantityBackOrdered]        DECIMAL(10, 3) NULL,
        [NetSalesAmount]             DECIMAL(13, 2) NULL,
        [ItemAllocationFlag]         DECIMAL(1, 0)  NULL,
        [PromiseDate]                DATE           NULL, -- DECIMAL(8, 0) 
        [LoadDate]                   DATE           NULL, --DECIMAL(8, 0)
        [ItemDescription]            VARCHAR(60)    NULL,
        [SellingPrice]               DECIMAL(15, 3) NULL,
        [BasePrice]                  DECIMAL(15, 3) NULL,
        [ItemClass]                  CHAR(4)        NULL,
        [CustomerNumber]             CHAR(8)        NULL,
        [ShiptoNumber]               CHAR(4)        NULL,
        [LastLoadDateChange]         DATETIME2(6)   NULL,
        [PreviousLoadDate]           DATETIME2(6)   NULL,
        [LastPreviousLoadDateChange] DATETIME2(6)   NULL,
        [EarliestLoadDate]           DATETIME2(6)   NULL,
        [LatestLoadDate]             DATETIME2(6)   NULL,
        [LoadDateChangeCount]        DECIMAL(3, 0)  NULL,
        [ItemWithLatestLoadDate]     CHAR(1)        NULL,
        [ItemProcessingStatus]       CHAR(1)        NULL,
        [OrderArrivalCode]           CHAR(2)        NULL,
        [MarkFor]                    VARCHAR(50)    NULL,
        [ItemLanguageDescription]    VARCHAR(30)    NULL,
        [UnitCost]                   DECIMAL(19, 8) NULL,
        [RecordCode]                 CHAR(2)        NULL,
        [WarehouseLocation]          CHAR(7)        NULL,
        [NonInventoryItem]           NUMERIC(1, 0)  NULL,
        [UnitOfMeasure]              CHAR(2)        NULL,
        [ExtendedWeightOverride]     NUMERIC(1, 0)  NULL,
        [ExtendedWeight]             DECIMAL(11, 3) NULL,
        [ContractUnitPrice]          DECIMAL(15, 3) NULL,
        [PriceOverride]              NUMERIC(1, 0)  NULL,
        [DiscountMarkup]             NUMERIC(1, 0)  NULL,
        [DiscountPercent]            DECIMAL(5, 3)  NULL,
        [QuantityDiscountPercent]    DECIMAL(5, 3)  NULL,
        [SellingPriceOverride]       NUMERIC(1, 0)  NULL,
        [NetSalesAmountOverride]     NUMERIC(1, 0)  NULL,
        [itemTypeCode]               CHAR(1)        NULL,
        [UnitWeight]                 DECIMAL(7, 3)  NULL,
        [CreditCode]                 CHAR(1)        NULL,
        [ManufacturiingOrderFlag]    CHAR(1)        NULL,
        [SalesAnalysisFlag]          NUMERIC(1, 0)  NULL,
        [MaterialRequestDate]        DATE           NULL, --  DECIMAL(8, 0)
        [MaintainedByProgram]        CHAR(1)        NULL,
        [PriceConversionMultiplier]  NUMERIC(7, 3)  NULL,
        [PriceCode]                  NUMERIC(1, 0)  NULL,
        [PricingUnitOfMeasure]       CHAR(2)        NULL,
        [PricingOverride]            NUMERIC(1, 0)  NULL,
        [ConvsionSellingPrice]       DECIMAL(17, 7) NULL,
        [CustomerRelEnt]             CHAR(1)        NULL,
        [RequestDateOverride]        NUMERIC(1, 0)  NULL,
        [MfgDueDateOverride]         NUMERIC(1, 0)  NULL,
        [MfgOrderNumber]             CHAR(7)        NULL,
        [ExportAdderCode]            CHAR(3)        NULL,
        [LC_ContractPrice]           DECIMAL(15, 3) NULL,
        [LC_BasePrice]               DECIMAL(15, 3) NULL,
        [LC_SellingPrice]            DECIMAL(15, 3) NULL,
        [LC_NetSalesAmount]          DECIMAL(13, 2) NULL,
        [LC_COnversionSellingPrice]  DECIMAL(17, 7) NULL,
        [PriceAdjustmentFactor]      DECIMAL(5, 2)  NULL,
        [TaxIndicator]               CHAR(3)        NULL
    );

GO
CREATE STATISTICS [Stat_OpenOrderDetail_PromiseDate]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [PromiseDate]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_QuantityShipped]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [QuantityShipped]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_QuantityBackOrdered]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [QuantityBackOrdered]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_BasePrice]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [BasePrice]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_OrderNumber]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [OrderNumber]
    );




GO
CREATE STATISTICS [Stat_OpenOrderDetail_ItemSKU]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_ItemSequence]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [ItemSequence]
    );




GO
CREATE STATISTICS [Stat_OpenOrderDetail_ItemDescription]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [ItemDescription]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_ItemClass]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [ItemClass]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_NetSalesAmount]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [NetSalesAmount]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_ItemAllocationFlag]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [ItemAllocationFlag]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_Warehouse]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [Warehouse]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_ShiptoNumber]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [ShiptoNumber]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_QuantiyOrdered]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [QuantiyOrdered]
    );


GO
CREATE STATISTICS [Stat_OpenOrderDetail_CustomerNumber]
    ON [CustomerOrders_AFI].[OpenOrderDetail]
    (
        [CustomerNumber]
    );

