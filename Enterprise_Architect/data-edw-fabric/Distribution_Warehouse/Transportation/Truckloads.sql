CREATE TABLE [Transportation].[Truckloads] (
    [TripNumber]        DECIMAL (7)      NULL,
    [Warehouse]         CHAR (3)         NULL,
    [TripStatus]        CHAR (1)         NULL,
    [Container]         VARCHAR (20)     NULL,
    [ContainerID]       CHAR (9)         NULL,
    [ContainerNumber]   CHAR (6)         NULL,
    [DoorNumber]        DECIMAL (4)      NULL,
    [PiecesRouted]      DECIMAL (6)      NULL,
    [Drops]             DECIMAL (2)      NULL,
    [Cubes]             DECIMAL (10)     NULL,
    [TotScanSerNumber]  DECIMAL (5)      NULL,
    [TotScanNoTag]      DECIMAL (5)      NULL,
    [CreatedDate]       DATE             NULL,  --Decimal(8)
    [CreatedTime]       DECIMAL (6)      NULL,
    [TripType]          VARCHAR (1)      NULL,
    [PercentComplete]   DECIMAL (28, 10) NULL,
    [PiecesLoaded]      DECIMAL (28, 10) NULL,
    [PiecesRemaining]   DECIMAL (28, 10) NULL,
    [Carrier]           VARCHAR (25)     NULL,
    [DispatchDate]      DATE             NULL,   --DECIMAL (8)
    [DispatchTime]      DECIMAL (4)      NULL,
    [LatestDeliverDate] DATE             NULL,   --DECIMAL (8)
    [State1]            CHAR (2)         NULL,
    [State2]            CHAR (2)         NULL,
    [State3]            CHAR (2)         NULL,
    [TripCreateDate]    DATE             NULL,   -- DECIMAL (8)
    [TripCreateTime]    DECIMAL (6)      NULL,
    [TrailerType]       VARCHAR (25)     NULL,
    [TripNumber7]       DECIMAL (7)      NULL
)


GO
CREATE STATISTICS [Stat_Truckloads_TripType]
    ON [Transportation].[Truckloads]([TripType]);


GO
CREATE STATISTICS [Stat_Truckloads_TripNumber]
    ON [Transportation].[Truckloads]([TripNumber]);


GO
CREATE STATISTICS [Stat_Truckloads_CreatedDate]
    ON [Transportation].[Truckloads]([CreatedDate]);


GO
CREATE STATISTICS [Stat_Truckloads_Warehouse]
    ON [Transportation].[Truckloads]([Warehouse]);


GO
CREATE STATISTICS [Stat_Truckloads_TripStatus]
    ON [Transportation].[Truckloads]([TripStatus]);


GO
CREATE STATISTICS [Stat_Truckloads_TripCreateTime]
    ON [Transportation].[Truckloads]([TripCreateTime]);


GO
CREATE STATISTICS [Stat_Truckloads_TripCreateDate]
    ON [Transportation].[Truckloads]([TripCreateDate]);


GO
CREATE STATISTICS [Stat_Truckloads_TrailerType]
    ON [Transportation].[Truckloads]([TrailerType]);


GO
CREATE STATISTICS [Stat_Truckloads_TotScanSerNumber]
    ON [Transportation].[Truckloads]([TotScanSerNumber]);


GO
CREATE STATISTICS [Stat_Truckloads_TotScanNoTag]
    ON [Transportation].[Truckloads]([TotScanNoTag]);


GO
CREATE STATISTICS [Stat_Truckloads_TripNumber7]
    ON [Transportation].[Truckloads]([TripNumber7]);


GO
CREATE STATISTICS [Stat_Truckloads_State3]
    ON [Transportation].[Truckloads]([State3]);


GO
CREATE STATISTICS [Stat_Truckloads_State2]
    ON [Transportation].[Truckloads]([State2]);


GO
CREATE STATISTICS [Stat_Truckloads_State1]
    ON [Transportation].[Truckloads]([State1]);


GO
CREATE STATISTICS [Stat_Truckloads_PiecesRouted]
    ON [Transportation].[Truckloads]([PiecesRouted]);


GO
CREATE STATISTICS [Stat_Truckloads_PiecesRemaining]
    ON [Transportation].[Truckloads]([PiecesRemaining]);


GO
CREATE STATISTICS [Stat_Truckloads_PiecesLoaded]
    ON [Transportation].[Truckloads]([PiecesLoaded]);


GO
CREATE STATISTICS [Stat_Truckloads_PercentComplete]
    ON [Transportation].[Truckloads]([PercentComplete]);


GO
CREATE STATISTICS [Stat_Truckloads_LatestDeliverDate]
    ON [Transportation].[Truckloads]([LatestDeliverDate]);


GO
CREATE STATISTICS [Stat_Truckloads_Drops]
    ON [Transportation].[Truckloads]([Drops]);


GO
CREATE STATISTICS [Stat_Truckloads_DoorNumber]
    ON [Transportation].[Truckloads]([DoorNumber]);


GO
CREATE STATISTICS [Stat_Truckloads_DispatchTime]
    ON [Transportation].[Truckloads]([DispatchTime]);


GO
CREATE STATISTICS [Stat_Truckloads_DispatchDate]
    ON [Transportation].[Truckloads]([DispatchDate]);


GO
CREATE STATISTICS [Stat_Truckloads_Cubes]
    ON [Transportation].[Truckloads]([Cubes]);


GO
CREATE STATISTICS [Stat_Truckloads_CreatedTime]
    ON [Transportation].[Truckloads]([CreatedTime]);


GO
CREATE STATISTICS [Stat_Truckloads_ContainerID]
    ON [Transportation].[Truckloads]([ContainerID]);


GO
CREATE STATISTICS [Stat_Truckloads_ContainerNumber]
    ON [Transportation].[Truckloads]([ContainerNumber]);


GO
CREATE STATISTICS [Stat_Truckloads_Container]
    ON [Transportation].[Truckloads]([Container]);


GO
CREATE STATISTICS [Stat_Truckloads_Carrier]
    ON [Transportation].[Truckloads]([Carrier]);

