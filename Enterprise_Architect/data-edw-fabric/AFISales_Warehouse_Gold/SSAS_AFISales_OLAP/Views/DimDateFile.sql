CREATE VIEW [SSAS_AFISALES_OLAP].[DimDateFile]
AS
    SELECT
        [Transaction Date],
        [Fiscal Year],
        [Fiscal Week],
        [Fiscal Month],
        [Fiscal Quarter],
        [Calendar Year],
        [Calendar Month],
        [Calendar Week],
        [Calendar Quarter],
        [Week Day],
        WeekdayID,
        [Simple Week],
        [Simple Week ID],
        [Commission Period],
        Holiday,
        [Fiscal Month Desc],
        [Fiscal Month Desc ID],
        [Calendar Month Desc],
        [Fiscal Quarter Desc],
        [Calendar Quarter Desc],
        [Fiscal Week Desc],
        [Fiscal Week Description],
        [Calendar Week Desc ID],
        [Calendar Week Desc],
        [Calendar Week Description],
        [Fiscal Week Ended],
        [Date Desc],
        [Fiscal Year Desc],
        [Calendar Year Desc]
    FROM
        AFISales_DW.DimDateFile;