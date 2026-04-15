CREATE TABLE [Quality_DW].[FactAFISalesForecast] (
    [RowID]                         BIGINT           NOT NULL,
    [Sequence Number]               DECIMAL (9)     NOT NULL,
    [AFI Item Number]               VARCHAR (15)    NULL,
    [AFI Warehouse]                 CHAR (3)        NULL,
    [DRP Planner ID]                VARCHAR (10)    NULL,
    [Forecast ID]                   VARCHAR (36)    NOT NULL,
    [Forecast Level Number]         DECIMAL (1)     NOT NULL,
    [Alternate ABC-3 Code]          CHAR (1)        NULL,
    [IP ABC Code]                   CHAR (1)        NULL,
    [Forecast Planner ID]           VARCHAR (10)    NULL,
    [Field 1]                       CHAR (2)        NULL,
    [Product Type]                  CHAR (2)        NULL,
    [Field 17]                      VARCHAR (30)    NULL,
    [Product Watch Code]            VARCHAR (1)     NOT NULL,
    [Part Flag]                     CHAR (5)        NULL,
    [Product Group ID]              VARCHAR (10)    NULL,
    [Forecast Type Code]            CHAR (1)        NOT NULL,
    [Valid Demand]                  DECIMAL (3)     NOT NULL,
    [Forced Sys Std Deviation]      DECIMAL (11, 2) NOT NULL,
    [Perminent Component Quantity]  DECIMAL (11, 2) NOT NULL,
    [Unit Price]                    DECIMAL (11, 5) NOT NULL,
    [Derived Forecast Factor]       DECIMAL (5, 3)  NOT NULL,
    [Derived Forecast Key]          VARCHAR (36)    NULL,
    [Derived Forecast Level Number] DECIMAL (1)     NOT NULL,
    [Unit Cost]                     DECIMAL (11, 5) NOT NULL,
    [Cubic Feet]                    DECIMAL (9, 4)  NOT NULL,
    [Trend Component Quantity]      DECIMAL (11, 2) NOT NULL,
    [Mgnmt Valid Demand]            DECIMAL (3)     NOT NULL,
    [ABC Primary Code]              CHAR (1)        NULL,
    [Vendor Name]                   VARCHAR (20)    NULL,
    [Period 1 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 2 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 3 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 4 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 5 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 6 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 7 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 8 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 9 Resultant Forecast]   DECIMAL (11)    NOT NULL,
    [Period 10 Resultant Forecast]  DECIMAL (11)    NOT NULL,
    [Period 11 Resultant Forecast]  DECIMAL (11)    NOT NULL,
    [Period 12 Resultant Forecast]  DECIMAL (11)    NOT NULL,
    [Total Forecasted Sales]        DECIMAL (20, 5) NULL,
    [Total Forecasted Costs]        DECIMAL (20, 5) NULL
)
;



GO
CREATE STATISTICS [Stat_FactAFISalesForecast_SequenceNumber]
    ON [Quality_DW].[FactAFISalesForecast]([Sequence Number]);


GO
CREATE STATISTICS [Stat_FactAFISalesForecast_ForecastID]
    ON [Quality_DW].[FactAFISalesForecast]([Forecast ID]);

