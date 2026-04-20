CREATE TABLE [AFISales_DW].[DimADLogins] (
    [RowNumber]        BIGINT       NULL,
    [ADLogins]         VARCHAR (25) NULL,
    [Customer Profile] VARCHAR (8)  NULL
)


GO
CREATE STATISTICS [Stat_DimADLogins_RowNumber]
    ON [AFISales_DW].[DimADLogins]([RowNumber]);


GO
CREATE STATISTICS [Stat_DimADLogins_CustomerProfile]
    ON [AFISales_DW].[DimADLogins]([Customer Profile]);


GO
CREATE STATISTICS [Stat_DimADLogins_ADLogins]
    ON [AFISales_DW].[DimADLogins]([ADLogins]);

