CREATE TABLE [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [OrderNumber]                   [CHAR](7)        NULL,
        [SequenceNumber]                [DECIMAL](7, 0)  NULL,
        [ItemSKU]                       [VARCHAR](15)    NULL,
        [Freight]                       [DECIMAL](12, 2) NULL,
        [Discount]                      [DECIMAL](12, 2) NULL,
        [DFIDiscount]                   [DECIMAL](12, 2) NULL,
        [BilltoMarketingSpecialist]     [DECIMAL](5, 0)  NULL,
        [ShiptoMarketingSpecialist]     [DECIMAL](5, 0)  NULL,
        [ExeptionID]                    [DECIMAL](7, 0)  NULL,
        [PromiseDate]                   DATE             NULL, -- [DECIMAL](8, 0)
        [PackageID]                     [VARCHAR](15)    NULL,
        [GroupingNumber]                [DECIMAL](4, 0)  NULL,
        [FreightAdjustment]             [DECIMAL](12, 2) NULL,
        [LineReleaseNumber]             [VARCHAR](20)    NULL,
        [GroupPriceExceptionID]         [DECIMAL](7, 0)  NULL,
        [IARVLMD]                       [CHAR](2)        NULL,
        [IPRCSTS]                       [CHAR](2)        NULL,
        [RoutingPurgeCount]             [DECIMAL](28, 0) NULL,
        [CustomerDiscountCode]          [CHAR](3)        NULL,
        [ItemDiscountClass]             [CHAR](2)        NULL,
        [CustomerCommissionCode]        [CHAR](3)        NULL,
        [PriceCode]                     [CHAR](6)        NULL,
        [CustomerFreightCode]           [CHAR](3)        NULL,
        [ItemDescription]              [DECIMAL](6, 4)  NULL,
        [CommissionReductionFlag]       [CHAR](1)       NULL,
        [StandardPrice]                 [DECIMAL](7, 2)  NULL,
        [DispatchDate]                  DATE             NULL, --[DECIMAL](8, 0)  NULL,
        [PlannedDiscpatchDate]          DATE             NULL, --  [DECIMAL](8, 0)  NULL,
        [PlannedRouteCompleteDate]      DATE             NULL, -- [DECIMAL](8, 0)  NULL,
        [OrderStatus]                   [CHAR](2)        NULL,
        [CommissionAdjustment]          [DECIMAL](12, 2) NULL,
        [BuyGroupCode]                  [VARCHAR](15)    NULL,
        [PriceAdderRate]                [DECIMAL](6, 4)  NULL,
        [CalcualtedPercentAllowance]    [DECIMAL](7, 4)  NULL,
        [OriinalInoiceForCredits]       [DECIMAL](6, 0)  NULL,
        [OriginalItemSeqDate]           DATE             NULL, -- [DECIMAL](8, 0)  NULL,
        [ItemFreightClass]              [CHAR](2)        NULL,
        [ItemCommissionClass]           [CHAR](2)        NULL,
        [ScheduledCount]                [DECIMAL](3, 0)  NULL,
        [CancelledfromSchedulerCount]   [DECIMAL](3, 0)  NULL,
        [AdvertisingAccrual]            [DECIMAL](12, 2) NULL,
        [ContractPrice]                 [DECIMAL](7, 2)  NULL,
        [ATP_Quantity]                  [DECIMAL](10, 3) NULL,
        [ATPQS_Quantity]                [DECIMAL](10, 3) NULL,
        [ATP_Availability]              [DECIMAL](10, 3) NULL,
        [ErrorComment]                  [VARCHAR](15)    NULL,
        [BilltoCommissionRate]          [DECIMAL](6, 4)  NULL,
        [ShiptoCommissionRate]          [DECIMAL](10, 4)  NULL,
        [TripReferenceNumber]           [DECIMAL](6, 0)  NULL,
        [ItemStatus]                    [CHAR](1)        NULL,
        [ItemPriority]                  [CHAR](1)        NULL,
        [TripNumber]                    [DECIMAL](6, 0)  NULL,
        [DropNumber]                    [NUMERIC](2, 0)  NULL,
        [BOLF_ControlNumber]            [NUMERIC](7, 0)  NULL,
        [CustomerNumber]                CHAR(8)          NULL, --  [DECIMAL](8, 0)  NULL,
        [State]                         [CHAR](2)        NULL,
        [CommissionReductionRate]       [DECIMAL](6, 4)  NULL,
        [originalCommissionRate]        [DECIMAL](6, 4)  NULL,
        [WarehouseOperationRate]        [DECIMAL](6, 4)  NULL,
        [RouteCreateDate]               DATE             NULL, -- [DECIMAL](8, 0)  NULL,
        [AutoReleaseDate]               DATE             NULL, --- [DECIMAL](8, 0)  NULL,
        [RouteFrozenCount]              [DECIMAL](3, 0)  NULL,
        [CrossedAtDockCount]            [DECIMAL](3, 0)  NULL,
        [SchedulerJobID]                [VARCHAR](18)    NULL,
        [OriginalScheduledDeliveryDate] DATE             NULL, -- DATE NULL,  -- [DECIMAL](8, 0)  NULL,
        [ConfirmedDeliveryDate]         DATE             NULL, --   [DECIMAL](8, 0)  NULL,
        [RouteFreezeDeliveryDate]       DATE             NULL, --  [DECIMAL](8, 0)  NULL,
        [RouteFinalizeDeliveryDate]     DATE             NULL, -- [DECIMAL](8, 0)  NULL,
        [PriorityCode]                  [DECIMAL](2, 0)  NULL,
        [PackageDiscountAllocation]     [DECIMAL](4, 3)  NULL,
        [PackagePrice]                  [DECIMAL](8, 2)  NULL,
        [OrigianlItemStatus]            [CHAR](1)        NULL,
        [PackageItemPrice]              [DECIMAL](8, 2)  NULL,
        [KeyAnchorItem]                 [DECIMAL](4, 3)  NULL,
        [IACHORITM]                     [VARCHAR](15)    NULL,
        [PackageDescription]            [VARCHAR](30)    NULL,
        [OrderPriority]                 [NUMERIC](2, 0)  NULL
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_ItemDescription]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [ItemDescription]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_SequenceNumber]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [SequenceNumber]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_PromiseDate]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [PromiseDate]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_PriceCode]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [PriceCode]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_OrderNumber]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [OrderNumber]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_ItemSKU]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [ItemSKU]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_GroupingNumber]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [GroupingNumber]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_GroupPriceExceptionID]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [GroupPriceExceptionID]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_BuyGroupCode]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [BuyGroupCode]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_Freight]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [Freight]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_ExeptionID]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [ExeptionID]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_ItemDiscountClass]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [ItemDiscountClass]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_Discount]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [Discount]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_CustomerDiscountCode]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [CustomerDiscountCode]
    );
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_DFIDiscount]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [DFIDiscount]
    );
 
 
 
GO
CREATE STATISTICS [Stat_OpenOrderExtendedItem_StandardPrice]
    ON [CustomerOrders_AFI].[OpenOrderExtendedItem]
    (
        [StandardPrice]
    );
 