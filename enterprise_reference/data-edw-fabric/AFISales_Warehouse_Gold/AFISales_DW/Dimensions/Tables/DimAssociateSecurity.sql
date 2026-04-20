CREATE TABLE [AFISales_DW].[DimAssociateSecurity] (
    [RowNumber]                       BIGINT       NULL,
    [Salesman Number]                 CHAR (5)     NULL,
    [Account Number]                  CHAR (8)     NULL,
    [Shipto Number]                   CHAR (4)     NULL,
    [Division Code]                   CHAR (1)     NULL,
    [Salesman Name]                   VARCHAR (25) NULL,
    [Customer Shipto Division Number] VARCHAR (15) NULL
)



GO
CREATE STATISTICS [Stat_DimAssociateSecurity_SalesmanNumber]
    ON [AFISales_DW].[DimAssociateSecurity]([Salesman Number]);


GO
CREATE STATISTICS [Stat_DimAssociateSecurity_RowNumber]
    ON [AFISales_DW].[DimAssociateSecurity]([RowNumber]);


GO
CREATE STATISTICS [Stat_DimAssociateSecurity_CustomerShipto]
    ON [AFISales_DW].[DimAssociateSecurity]([Customer Shipto Division Number]);


GO
CREATE STATISTICS [Stat_DimAssociateSecurity_Shipto_Number]
    ON [AFISales_DW].[DimAssociateSecurity]([Shipto Number]);


GO
CREATE STATISTICS [Stat_DimAssociateSecurity_Salesman_Name]
    ON [AFISales_DW].[DimAssociateSecurity]([Salesman Name]);


GO
CREATE STATISTICS [Stat_DimAssociateSecurity_Division_Code]
    ON [AFISales_DW].[DimAssociateSecurity]([Division Code]);


GO
CREATE STATISTICS [Stat_DimAssociateSecurity_Account_Number]
    ON [AFISales_DW].[DimAssociateSecurity]([Account Number]);

