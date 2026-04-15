CREATE TABLE [Quality_DW].[FactCurrentSalesForecast] (
    [RowID]             BIGINT          NOT NULL,
    [AFI Item Number]   VARCHAR (15)    NOT NULL,
    [AFI Warehouse]     CHAR (3)        NOT NULL,
    [Location Code]     CHAR (5)        NULL,
    [Vendor Number]     CHAR (8)        NOT NULL,
    [Forecast Quantity] DECIMAL (15, 2) NOT NULL,
    [Forecast Sales]    DECIMAL (15, 2) NOT NULL,
    [Forecast Costs]    DECIMAL (15, 2) NOT NULL,
    [Site ID]           CHAR (3)        NOT NULL
)
;






GO
CREATE STATISTICS [Stat_FactCurrentSalesForecast_Vendor_Number]
    ON [Quality_DW].[FactCurrentSalesForecast]([Vendor Number]);


GO
CREATE STATISTICS [Stat_FactCurrentSalesForecast_AFI_Warehouse]
    ON [Quality_DW].[FactCurrentSalesForecast]([AFI Warehouse]);


GO
CREATE STATISTICS [Stat_FactCurrentSalesForecast_AFI_Item_Number]
    ON [Quality_DW].[FactCurrentSalesForecast]([AFI Item Number]);

