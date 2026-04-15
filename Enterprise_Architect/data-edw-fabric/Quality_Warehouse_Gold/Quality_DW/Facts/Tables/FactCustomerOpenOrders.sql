CREATE TABLE [Quality_DW].[FactCustomerOpenOrders] (
    [CurrentOrders] DECIMAL (13, 3) NULL,
    [ReqDate]       DATE            NULL,
    [Item]          VARCHAR (8000)  NULL,
    [House]         VARCHAR (3)     NULL
)
;
GO


CREATE STATISTICS [Stat_FactCustomerOpenOrders_CurrentOrders]
    ON [Quality_DW].[FactCustomerOpenOrders]([CurrentOrders]);
GO

CREATE STATISTICS [Stat_FactCustomerOpenOrders_House]
    ON [Quality_DW].[FactCustomerOpenOrders]([House]);
GO

CREATE STATISTICS [Stat_FactCustomerOpenOrders_Item]
    ON [Quality_DW].[FactCustomerOpenOrders]([Item]);
GO

CREATE STATISTICS [Stat_FactCustomerOpenOrders_ReqDate]
    ON [Quality_DW].[FactCustomerOpenOrders]([ReqDate]);
GO

