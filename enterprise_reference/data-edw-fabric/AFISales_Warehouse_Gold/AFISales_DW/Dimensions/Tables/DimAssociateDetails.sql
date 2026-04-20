CREATE TABLE [AFISales_DW].[DimAssociateDetails] (
    [RowNumber]       BIGINT       NULL,
    [Salesman Number] CHAR (5)     NULL,
    [Salesman Name]   VARCHAR (25) NULL
)

GO
CREATE STATISTICS [Stat_DimAssociateDetails_SalesmanNumber]
    ON [AFISales_DW].[DimAssociateDetails]([Salesman Number]);


GO
CREATE STATISTICS [Stat_DimAssociateDetails_RowNumber]
    ON [AFISales_DW].[DimAssociateDetails]([RowNumber]);


GO
CREATE STATISTICS [Stat_DimAssociateDetails_SalesmanName]
    ON [AFISales_DW].[DimAssociateDetails]([Salesman Name]);


