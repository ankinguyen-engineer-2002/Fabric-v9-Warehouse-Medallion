CREATE TABLE [AFISales_DW].[DimWarehouseMaster] (
    [Warehouse Code]             CHAR (3)       NULL,
    [Intransit Warehouse]        CHAR (3)       NULL,
    [Container Direct Warehouse] CHAR (1)       NULL,
    [Controlled Warehouse]       INT            NULL,
    [Warehouse Location]         VARCHAR (50)   NULL,
    [Warehouse Order Group]      VARCHAR (10)   NULL,
    [Order Release Minimum]      INT            NULL
)

