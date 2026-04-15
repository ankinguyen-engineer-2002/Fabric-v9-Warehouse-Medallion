
CREATE TABLE [AFISales_Enh].[OnTimeDeliveryDetail] (
    [Week]                     INT             NULL,
    [Warehouse]                CHAR (3)        NULL,
    [TripNumber]               DECIMAL (7)     NULL,
    [CustomerNumber]           CHAR (8)        NOT NULL,
    [ShiptoNumber]             CHAR (4)        NULL,
    [ItemSKU]                  VARCHAR (15)    NULL,
    [Year]                     INT             NULL,
    [Period]                   INT             NULL,
    [InvoiceDate]              DATE            NULL,
    [ItemStatus]               CHAR (1)        NULL,
    [HomeStore]                CHAR (1)        NULL,
    [OrderType2]               CHAR (1)        NULL,
    [OrderType3]               CHAR (1)        Null,
    [ShippedQuantity]          DECIMAL (10, 3) NULL,
    [OrderToDelivery]          DECIMAL (9, 1)  NULL,
    [OrgPromToDelivery]        DECIMAL (9, 1)  NULL,
    [InvoiceToDelivery]        DECIMAL (9, 1)  NULL,
    [CurReqToDelivery]         DECIMAL (9, 1)  NULL,
    [FirstScanToTripClose]     DECIMAL (9, 1)  NULL,
    [TripCloseToDelivery]      DECIMAL (9, 1)  NULL,
    [OrigReqtoDelivery]        DECIMAL (9, 1)  NULL,
    [OrderToFirstScan]         DECIMAL (9, 1)  NULL,
    [TripCreateToTripClose]    DECIMAL (9, 1)  NULL,
    [TripCreateToFirstScan]    DECIMAL (9, 1)  NULL,
    [OrdertoTripCreate]        DECIMAL (9, 1)  NULL,
    [CurPromisetoDelivery]     DECIMAL (9, 1)  NULL,
    [OrderToOriginalRequest]   DECIMAL (9, 1)  NULL,
    [QtyOnTimeOrigPromiseDay]  DECIMAL (10, 3) NULL,
    [QtyOnTimeOrigPromiseWeek] DECIMAL (10, 3) NULL,
    [QtyOnTimeCurReqDay]       DECIMAL (10, 3) NULL,
    [QtyOnTimeCurReqWeek]      DECIMAL (10, 3) NULL,
    [QtyOnTimeOrigReqDay]      DECIMAL (10, 3) NULL,
    [QtyOnTimeOrigReqWeek]     DECIMAL (10, 3) NULL,
    [QtyOnTimeCurPromDay]      DECIMAL (10, 3) NULL,
    [QtyOnTimeCurPromWeek]     DECIMAL (10, 3) NULL,
    [State]                    CHAR (2)        NULL,
    [Country]                  CHAR (3)        NULL,
    [MSA]                      CHAR (5)        NULL,
    [ItemClass]                CHAR (4)        NULL,
    [Division]                 CHAR (1)        NULL,
    [TerritoryCode]            CHAR (5)        NULL,
    [RouteZone]                CHAR (3)        NULL,
    [RouteRegion]              CHAR (3)        NULL,
    [SalesCategory]            CHAR (3)        NULL,
    [CssRep]                   CHAR (5)        NULL,
    [BusinessType]             CHAR (2)        NULL,
    [County]                   CHAR (3)        NULL,
    [ImportDomestic]           CHAR (1)        NULL,
    [OrderDate]                DATE            NULL,
    [DeliveryDate]             DATE            NULL,
    [OriginalPromiseDate]      DATE            NULL,
    [CurrentRequestDate]       DATE            NULL,
    [FirstScanDate]            DATETIME2 (6)   NULL,  -- DATETIME
    [TripCreateDate]           DATETIME2 (6)   NULL,  -- DATETIME
    [TripCloseDate]            DATETIME2 (6)   NULL,  -- DATETIME
    [CurrentPromiseDate]       DATE            NULL,
    [OriginalRequestDate]      DATE            NULL
    
)


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_TripCreateDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([TripCreateDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_TripCloseDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([TripCloseDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_Year]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([Year]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_Week]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([Week]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_Warehouse]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([Warehouse]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_TripNumber]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([TripNumber]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_TripCreateToTripClose]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([TripCreateToTripClose]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_TripCreateToFirstScan]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([TripCreateToFirstScan]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_TripCloseToDelivery]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([TripCloseToDelivery]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_TerritoryCode]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([TerritoryCode]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_State]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([State]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_SalesCategory]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([SalesCategory]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_ShiptoNumber]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_ShippedQuantity]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([ShippedQuantity]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_RouteZone]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([RouteZone]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_RouteRegion]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([RouteRegion]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeOrigReqWeek]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeOrigReqWeek]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeOrigReqDay]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeOrigReqDay]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeOrigPromiseWeek]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeOrigPromiseWeek]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeOrigPromiseDay]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeOrigPromiseDay]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeCurReqWeek]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeCurReqWeek]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeCurReqDay]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeCurReqDay]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeCurPromWeek]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeCurPromWeek]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_QtyOnTimeCurPromDay]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([QtyOnTimeCurPromDay]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_Period]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([Period]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrigReqtoDelivery]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrigReqtoDelivery]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrgPromToDelivery]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrgPromToDelivery]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrderType2]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrderType2]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrdertoTripCreate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrdertoTripCreate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrderToOriginalRequest]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrderToOriginalRequest]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrderToFirstScan]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrderToFirstScan]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrderToDelivery]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrderToDelivery]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_MSA]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([MSA]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_ItemStatus]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([ItemStatus]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_ItemSKU]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([ItemSKU]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_ItemClass]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([ItemClass]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_InvoiceToDelivery]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([InvoiceToDelivery]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_InvoiceDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([InvoiceDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_ImportDomestic]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([ImportDomestic]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_HomeStore]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([HomeStore]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_FirstScanToTripClose]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([FirstScanToTripClose]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_Division]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([Division]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_CurReqToDelivery]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([CurReqToDelivery]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_CurPromisetoDelivery]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([CurPromisetoDelivery]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_CssRep]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([CssRep]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_County]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([County]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_Country]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([Country]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_BusinessType]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([BusinessType]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_CustomerNumber]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([CustomerNumber]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OriginalRequestDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OriginalRequestDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OriginalPromiseDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OriginalPromiseDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_OrderDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([OrderDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_FirstScanDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([FirstScanDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_DeliveryDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([DeliveryDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_CurrentRequestDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([CurrentRequestDate]);


GO
CREATE STATISTICS [Stat_OnTimeDeliveryDetail_CurrentPromiseDate]
    ON [AFISales_Enh].[OnTimeDeliveryDetail]([CurrentPromiseDate]);

