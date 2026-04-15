CREATE TABLE [AFISales_DW].[FactADLoginsAndCustomer] (
    [RowID]                     BIGINT       NOT NULL, --  IDENTITY (1, 1)
    [ADLogins]                  VARCHAR (25) NOT NULL,
    [Account And Shipto Number] CHAR (13)    NULL
)


GO
CREATE STATISTICS [Stat_FactADLogins]
    ON [AFISales_DW].[FactADLoginsAndCustomer]([ADLogins]);

