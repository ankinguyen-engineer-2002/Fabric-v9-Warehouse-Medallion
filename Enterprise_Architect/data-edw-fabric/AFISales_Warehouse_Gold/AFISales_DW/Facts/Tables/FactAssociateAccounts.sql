CREATE TABLE [AFISales_DW].[FactAssociateAccounts] (
    [RowID]                     BIGINT    NULL,
    [Salesman Number]           CHAR (5)  NULL,
    [Account And Shipto Number] CHAR (13) NULL
)

GO
CREATE STATISTICS [Stat_FactAssociateAccounts_SalesmanNumber]
    ON [AFISales_DW].[FactAssociateAccounts]([Salesman Number]);


GO
CREATE STATISTICS [Stat_FactAssociateAccounts_RowID]
    ON [AFISales_DW].[FactAssociateAccounts]([RowID]);


GO
CREATE STATISTICS [Stat_FactAssociateAccounts_AccountShipttoNumber]
    ON [AFISales_DW].[FactAssociateAccounts]([Account And Shipto Number]);

