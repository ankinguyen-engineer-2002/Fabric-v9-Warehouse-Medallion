CREATE TABLE [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [OrderNumber]    VARCHAR(7)  NULL,
        [CustomerNumber] NUMERIC(8)  NULL,
        [ShiptoNumber]   CHAR(4)     NULL,
        [OldRequestDate] NUMERIC(8)  NULL,
        [NewRequestDate] NUMERIC(8)  NULL,
        [Reason]         CHAR(2)     NULL,
        [ChangeDate]     NUMERIC(8)  NULL,
        [ChangeItem]     NUMERIC(6)  NULL,
        [ChangeUser]     VARCHAR(10) NULL
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_ShiptoNumber]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [ShiptoNumber]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_REASON]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [Reason]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_ORDERNUMBER]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [OrderNumber]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_CUSTOMERNUMBER]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [CustomerNumber]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_OldRequestDate]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [OldRequestDate]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_NewRequestDate]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [NewRequestDate]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_ChangeUser]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [ChangeUser]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_ChangeItem]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [ChangeItem]
    );


GO
CREATE STATISTICS [Stat_RequestDateChangeAudit_ChangeDate]
    ON [CustomerOrders_AFI].[RequestDateChangeAudit]
    (
        [ChangeDate]
    );

