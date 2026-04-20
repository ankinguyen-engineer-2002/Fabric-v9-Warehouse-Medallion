
CREATE TABLE [Quality_DW].[FactWarehouseItemStatus] (
    [serialNumber]  BIGINT        NULL,
    [ItemNumber]    VARCHAR (17)  NULL,
    [PoNumber]      VARCHAR (10)  NULL,
    [Warehouse]     CHAR (3)      NULL,
    [CreateDate]    DATETIME2 (6) NULL,
    [Status]        VARCHAR (1)   NULL,
    [Serial_number] VARCHAR (30)  NULL,
    [SerialStatus]  CHAR (1)      NULL,
    [MasterStatus]  CHAR (1)      NULL,
    [LocationID]    VARCHAR (50)  NULL
)


GO

