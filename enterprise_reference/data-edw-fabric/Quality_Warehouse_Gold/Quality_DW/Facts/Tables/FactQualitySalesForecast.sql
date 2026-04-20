CREATE TABLE [Quality_DW].[FactQualitySalesForecast] (
    [RowID]             BIGINT          NOT NULL,
    [Forecast Date]     DATE            NOT NULL,
    [AFI Item Number]   VARCHAR (15)    NOT NULL,
    [AFI Warehouse]     CHAR (3)        NOT NULL,
    [Location Code]     CHAR (5)        NULL,
    [Vendor Number]     CHAR (8)        NOT NULL,
    [Forecast Quantity] DECIMAL (15, 2) NOT NULL,
    [Forecast Sales]    DECIMAL (15, 2) NOT NULL,
    [Forecast Costs]    DECIMAL (15, 2) NOT NULL,
    [Site ID]           CHAR (3)        NOT NULL
)

GO
CREATE STATISTICS [Stat_FactQualitySalesForecast_ForecastDate]
    ON [Quality_DW].[FactQualitySalesForecast]([Forecast Date]);


GO
CREATE STATISTICS [Stat_FactQualitySalesForecast_AFIWarehouse]
    ON [Quality_DW].[FactQualitySalesForecast]([AFI Warehouse]);


GO
CREATE STATISTICS [Stat_FactQualitySalesForecast_AFIItemNumber]
    ON [Quality_DW].[FactQualitySalesForecast]([AFI Item Number]);

