CREATE TABLE [AFISales_DW].[DimMarketingSpecialists] (
    [Salesman Number]       CHAR (5)     NULL,
    [Salesman Name]         VARCHAR (25) NULL,
    [Saleman Business Name] VARCHAR (41) NULL,
    [Sales Position]        VARCHAR (20) NOT NULL
)


GO
CREATE STATISTICS [Stat_DimmMarketingSpecialists_SalesmanNumber]
    ON [AFISales_DW].[DimMarketingSpecialists]([Salesman Number]);


