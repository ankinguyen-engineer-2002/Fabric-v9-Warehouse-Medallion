CREATE TABLE [Quality_DW].[FactWarehouseDamages] (
    [Damage ID]                 BIGINT            NOT NULL,
    [Reference Number]          VARCHAR (10)     NOT NULL,
    [Transaction date]          DATE             NULL,
    [Transaction Code]          CHAR (2)         NOT NULL,
    [Item Number]               VARCHAR (15)     NOT NULL,
    [From warehouse]            CHAR (3)         NULL,
    [To warehouse]              CHAR (3)         NOT NULL,
    [Location Code]             CHAR (5)         NULL,
    [Reason Code]               CHAR (6)         NOT NULL,
    [Other Warehouses]          CHAR (4)         NULL,
    [Vendor Number]             CHAR (8)         NULL,
    [Extended Cost]             DECIMAL (20, 5)  NULL,
    [Extended Cubes]            DECIMAL (18, 7)  NULL,
    [Warehouse Damage Quantity] DECIMAL (12, 2)  NULL,
    [Warehouse Damage Cost]     DECIMAL (22, 10) NULL,
    [Transfer Damage Quantity]  DECIMAL (12, 2)  NULL,
    [Transfer Damage Cost]      DECIMAL (22, 10) NULL
)


