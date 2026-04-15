
CREATE TABLE [CustomerOrders_AFI].[OrderSchedule] ---ORDSCHD
    (
        [GroupNumber]                 CHAR(18)      NOT NULL,
        [OrderNumber]                 CHAR(7)       NOT NULL,
        [ItemSKU]                     CHAR(15)      NOT NULL,
        [ItemSequence]                DECIMAL(7)    NOT NULL,
        [ReferenceNumber]             DECIMAL(6)    NOT NULL,
        [CompanyNumber]               DECIMAL(2)    NOT NULL,
        [CustomerNumber]              DECIMAL(8)    NOT NULL,
        [ShiptoNumber]                CHAR(4)       NOT NULL,
        [CustomerServiceRepID]        DECIMAL(5)    NOT NULL,
        [Warehouse]                   CHAR(3)       NOT NULL,
        [TotalCubes]                  DECIMAL(7, 2) NOT NULL,
        [TotalWeight]                 DECIMAL(8, 2) NOT NULL,
        [Pieces]                      DECIMAL(7)    NOT NULL,
        [NetSales]                    DECIMAL(9, 2) NOT NULL,
        [LoadDate]                    DATE          NOT NULL,
        [DeliveryAppointmentFromDate] DECIMAL(8)    NOT NULL,
        [DeliveryAppointmenToDate]    DECIMAL(8)    NOT NULL,
        [DeliveryAppointmentFromTime] DECIMAL(6)    NOT NULL,
        [DeliveryAppointmentToTime]   DECIMAL(6)    NOT NULL,
        [WindowFromDate1]             DATE              NULL,
        [WindowToDate1]               DATE              NULL,
        [WindowFromTime1]             DECIMAL(6)    NOT NULL,
        [WindowToTime1]               DECIMAL(6)    NOT NULL,
        [WindowFrequency1]            CHAR(7)       NOT NULL,
        [WindowFromDate2]             DATE              NULL,
        [WindowToDate2]               DATE              NULL,
        [WindowFromTime2]             DECIMAL(6)    NOT NULL,
        [WindowToTime2]               DECIMAL(6)    NOT NULL,
        [WindowFrequency2]            CHAR(7)       NOT NULL,
        [WindowFromDate3]             DATE              NULL,
        [WindowToDate3]               DATE              NULL,
        [WindowFromTime3]             DECIMAL(6)    NOT NULL,
        [WindowToTime3]               DECIMAL(6)    NOT NULL,
        [WindowFrequency3]            CHAR(7)       NOT NULL,
        [WindowFromDate4]             DATE              NULL,
        [WindowToDate4]               DATE              NULL,
        [WindowFromTime4]             DECIMAL(6)    NOT NULL,
        [WindowToTime4]               DECIMAL(6)    NOT NULL,
        [WindowFrequency4]            CHAR(7)       NOT NULL,
        [WindowFromDate5]             DATE              NULL,
        [WindowToDate5]               DATE              NULL,
        [WindowFromTime5]             DECIMAL(6)    NOT NULL,
        [WindowToTime5]               DECIMAL(6)    NOT NULL,
        [WindowFrequency5]            CHAR(7)       NOT NULL,
        [WindowFromDate6]             DATE              NULL,
        [WindowToDate6]               DATE              NULL,
        [WindowFromTime6]             DECIMAL(6)    NOT NULL,
        [WindowToTime6]               DECIMAL(6)    NOT NULL,
        [WindowFrequency6]            CHAR(7)       NOT NULL,
        [WindowFromDate7]             DATE              NULL,
        [WindowToDate7]               DATE              NULL,
        [WindowFromTime7]             DECIMAL(6)    NOT NULL,
        [WindowToTime7]               DECIMAL(6)    NOT NULL,
        [WindowFrequency7]            CHAR(7)       NOT NULL,
        [WindowFromDate8]             DATE              NULL,
        [WindowToDate8]               DATE              NULL,
        [WindowFromTime8]             DECIMAL(6)    NOT NULL,
        [WindowToTime8]               DECIMAL(6)    NOT NULL,
        [WindowFrequency8]            CHAR(7)       NOT NULL,
        [WindowFromDate9]             DATE              NULL,
        [WindowToDate9]               DATE              NULL,
        [WindowFromTime9]             DECIMAL(6)    NOT NULL,
        [WindowToTime9]               DECIMAL(6)    NOT NULL,
        [WindowFrequency9]            CHAR(7)       NOT NULL,
        [RoutingStatus]               CHAR(1)       NOT NULL,
        [PurchaseOrder]               CHAR(22)      NOT NULL,
        [CustomerRequestDate]         DATE              NULL,
        [RoutePlanner]                CHAR(10)      NOT NULL,
        [DateAdded]                   DECIMAL(8)    NOT NULL,
        [TimeAdded]                   DECIMAL(6)    NOT NULL,
        [AddedByUser]                 CHAR(10)      NOT NULL,
        [DateChanged]                 DATE              NULL,
        [TimeChanged]                 DECIMAL(6)    NOT NULL,
        [ChangedByUser]               CHAR(10)      NOT NULL,
        [DeliveryDate]                DATE              NULL
    );


GO

CREATE STATISTICS [stat_CODIS_AFI_OrderSchedule_GroupNumber]
    ON [CustomerOrders_AFI].[OrderSchedule]
    (
        [GroupNumber]
    );


GO
CREATE STATISTICS [stat_codis_afi_AFI_OrderSchedule_OrderNumber]
    ON [CustomerOrders_AFI].[OrderSchedule]
    (
        [OrderNumber]
    );


GO
CREATE STATISTICS [stat_CODIS_AFI_OrderSchedule_ItemSKU]
    ON [CustomerOrders_AFI].[OrderSchedule]
    (
        [ItemSKU]
    );


GO
CREATE STATISTICS [stat_CODIS_AFI_OrderSchedule_ItemSequence]
    ON [CustomerOrders_AFI].[OrderSchedule]
    (
        [ItemSequence]
    );


GO