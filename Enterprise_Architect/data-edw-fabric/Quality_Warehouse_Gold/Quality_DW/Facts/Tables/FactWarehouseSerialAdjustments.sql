CREATE TABLE [Quality_DW].[FactWarehouseSerialAdjustments]
(
    [Warehouse] [char](3) NOT NULL,
    [Item] [varchar](15) NOT NULL,
    [Orphaned] [int] NULL,
    [In Warehouse] [int] NOT NULL,
    [Shipped] [int] NULL,
    [Hold] [int] NOT NULL,
    [Loaded] [int] NULL
)
GO
CREATE STATISTICS [stat_FactWarehouseSerialAdjustments_Item] ON Quality_DW.FactWarehouseSerialAdjustments([Item])

 

Go
CREATE STATISTICS [stat_FactWarehouseSerialAdjustments_Warehouse] ON [Quality_DW].FactWarehouseSerialAdjustments([Warehouse])