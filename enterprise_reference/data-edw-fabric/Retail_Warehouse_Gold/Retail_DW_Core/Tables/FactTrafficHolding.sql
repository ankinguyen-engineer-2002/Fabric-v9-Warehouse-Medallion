CREATE TABLE [Retail_DW_Core].[FactTrafficHolding] (
    [DataSource]      VARCHAR (5)     NULL,
    [DeviceSourceID]  VARCHAR (20)    NULL,
    [StoreID]         INT             NOT NULL,
    [TransDate]       DATE            NOT NULL,
    [TransDay]        INT             NOT NULL,
    [TransHour]       DECIMAL (18, 2) NOT NULL,
    [TransHourMinute] DECIMAL (18, 2) NOT NULL,
    [TransCount]      DECIMAL (18, 2) NULL,
    [IsOpen]          INT             NULL,
    [LastUpdated]     DATETIME2 (3)   NULL,
    [TrafficCount]    DECIMAL (18, 2) NULL,
    [RSAMinutes]      INT             NULL,
    [IsOverride]      INT             NULL
);
GO

