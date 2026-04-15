create TABLE [MasterData_DW].[DimTime] (
    [TimeKey]               INT          NOT NULL,
    [TimeID]                INT          NOT NULL,
    [TimeOfDayMilitary]     BIGINT       NULL,
    [TimeOfDayAMPM]         VARCHAR (11) NULL,
    [HourOfDayMilitaryID]   BIGINT       NULL,
    [HourOfDayAMPMID]       VARCHAR (5)  NULL,
    [HourOfDayMilitary]     BIGINT       NULL,
    [HourOfDayAMPM]         VARCHAR (11) NULL,
    [QuarterOfHourID]       INT          NULL,
    [QuarterOfHourMilitary] BIGINT       NULL,
    [QuarterOfHourAMPM]     VARCHAR (11) NULL,
    [MinuteOfHourID]        INT          NULL,
    [MinuteOfDayMilitary]   BIGINT       NULL,
    [MinuteOfDayAMPM]       VARCHAR (11) NULL,
    [SecondOfMinuteID]      INT          NULL,
    [AMPM]                  VARCHAR (2)  NULL,
    [HourOfDayAMPMRange]    VARCHAR (17) NULL
)




GO
CREATE STATISTICS [Stat_DimTime_TimeOfDayMilitary]
    ON [MasterData_DW].[DimTime]([TimeOfDayMilitary]);


GO
CREATE STATISTICS [Stat_DimTime_TimeOfDayAMPM]
    ON [MasterData_DW].[DimTime]([TimeOfDayAMPM]);


GO
CREATE STATISTICS [Stat_DimTime_TimeID]
    ON [MasterData_DW].[DimTime]([TimeID]);


GO
CREATE STATISTICS [Stat_DimTime_SecondOfMinuteID]
    ON [MasterData_DW].[DimTime]([SecondOfMinuteID]);


GO
CREATE STATISTICS [Stat_DimTime_QuarterOfHourMilitary]
    ON [MasterData_DW].[DimTime]([QuarterOfHourMilitary]);


GO
CREATE STATISTICS [Stat_DimTime_QuarterOfHourID]
    ON [MasterData_DW].[DimTime]([QuarterOfHourID]);


GO
CREATE STATISTICS [Stat_DimTime_QuarterOfHourAMPM]
    ON [MasterData_DW].[DimTime]([QuarterOfHourAMPM]);


GO
CREATE STATISTICS [Stat_DimTime_MinuteOfHourID]
    ON [MasterData_DW].[DimTime]([MinuteOfHourID]);


GO
CREATE STATISTICS [Stat_DimTime_MinuteOfDayMilitary]
    ON [MasterData_DW].[DimTime]([MinuteOfDayMilitary]);


GO
CREATE STATISTICS [Stat_DimTime_MinuteOfDayAMPM]
    ON [MasterData_DW].[DimTime]([MinuteOfDayAMPM]);


GO
CREATE STATISTICS [Stat_DimTime_HourOfDayMilitaryID]
    ON [MasterData_DW].[DimTime]([HourOfDayMilitaryID]);


GO
CREATE STATISTICS [Stat_DimTime_HourOfDayMilitary]
    ON [MasterData_DW].[DimTime]([HourOfDayMilitary]);


GO
CREATE STATISTICS [Stat_DimTime_HourOfDayAMPMRange]
    ON [MasterData_DW].[DimTime]([HourOfDayAMPMRange]);


GO
CREATE STATISTICS [Stat_DimTime_HourOfDayAMPMID]
    ON [MasterData_DW].[DimTime]([HourOfDayAMPMID]);


GO
CREATE STATISTICS [Stat_DimTime_HourOfDayAMPM]
    ON [MasterData_DW].[DimTime]([HourOfDayAMPM]);


GO
CREATE STATISTICS [Stat_DimTime_DateKey]
    ON [MasterData_DW].[DimTime]([TimeKey]);


GO
CREATE STATISTICS [Stat_DimTime_AMPM]
    ON [MasterData_DW].[DimTime]([AMPM]);

