CREATE TABLE [CustomerOrders_AFI].[SchedulerControl] ---SCHCTL
    (
        [GroupNumber]          VARCHAR(18)    NULL,
        [CustomerNumber]       DECIMAL(28)    NULL,
        [ShiptoNumber]         CHAR(4)        NULL,
        [WindowFromDate9]      DATE           NULL,
        [WindowFromDate8]      DATE           NULL,
        [WindowFromDate7]      DATE           NULL,
        [WindowFromDate6]      DATE           NULL,
        [WindowFromDate5]      DATE           NULL,
        [WindowFromDate4]      DATE           NULL,
        [WindowFromDate3]      DATE           NULL,
        [WindowFromDate2]      DATE           NULL,
        [WindowFromDate1]      DATE           NULL,
        [WindowFromTime9]      DECIMAL(28)    NULL,
        [WindowFromTime8]      DECIMAL(28)    NULL,
        [WindowFromTime7]      DECIMAL(28)    NULL,
        [WindowFromTime6]      DECIMAL(28)    NULL,
        [WindowFromTime5]      DECIMAL(28)    NULL,
        [WindowFromTime4]      DECIMAL(28)    NULL,
        [WindowFromTime3]      DECIMAL(28)    NULL,
        [WindowFromTime2]      DECIMAL(28)    NULL,
        [WindowFromTime1]      DECIMAL(28)    NULL,
        [WindowToDate9]        DATE           NULL,
        [WindowToDate8]        DATE           NULL,
        [WindowToDate7]        DATE           NULL,
        [WindowToDate6]        DATE           NULL,
        [WindowToDate5]        DATE           NULL,
        [WindowToDate4]        DATE           NULL,
        [WindowToDate3]        DATE           NULL,
        [WindowToDate2]        DATE           NULL,
        [WindowToDate1]        DATE           NULL,
        [WindowToTime9]        DECIMAL(28)    NULL,
        [WindowToTime8]        DECIMAL(28)    NULL,
        [WindowToTime7]        DECIMAL(28)    NULL,
        [WindowToTime6]        DECIMAL(28)    NULL,
        [WindowToTime5]        DECIMAL(28)    NULL,
        [WindowToTime3]        DECIMAL(28)    NULL,
        [WindowToTime4]        DECIMAL(28)    NULL,
        [WindowToTime2]        DECIMAL(28)    NULL,
        [WindowToTime1]        DECIMAL(28)    NULL,
        [RouteZone]            CHAR(3)        NULL,
        [CompanyNumber]        DECIMAL(28)    NULL,
        [LoadDate]             DATE           NULL,
        [Cubes]                DECIMAL(28, 2) NULL,
        [ConfirmationDate]     DATE           NULL,
        [RoutePlanner]         VARCHAR(10)    NULL,
        [AssignedRoute]        VARCHAR(20)    NULL,
        [CustomerServiceRepID] DECIMAL(28)    NULL,
        [Warehouse]            CHAR(3)        NULL,
        [TripType]             CHAR(1)        NULL,
        [DeliveryDate]         DATETIME2 (6)  NULL
    );


GO

CREATE STATISTICS [stat_CODIS_AFI_SchedulerControl_GroupNumber]
    ON [CustomerOrders_AFI].[SchedulerControl]
    (
        [GroupNumber]
    );


GO
