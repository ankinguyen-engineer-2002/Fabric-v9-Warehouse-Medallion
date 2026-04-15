CREATE TABLE [AFISales_DW].[DimOrderHistoryDetails] (
    [Order Change Date]    DATE         NULL,
    [Order Number]         VARCHAR (10) NULL,
    [Order Sequence]       INT          NOT NULL,
    [Request Date]         DATE         NULL,
    [Order Arrival Mode]   VARCHAR (25) NULL,
    [Primary Order Type]   VARCHAR (30) NULL,
    [Secondary Order Type] VARCHAR (30) NULL,
    [3rd Order Type]       VARCHAR (30) NULL,
    [4th Order Type]       VARCHAR (30) NULL,
    [Reason code]          VARCHAR (30) NULL 

)


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_OrderNumber]
    ON [AFISales_DW].[DimOrderHistoryDetails]([Order Number]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_OrderChangeDate]
    ON [AFISales_DW].[DimOrderHistoryDetails]([Order Change Date]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_Secondary_Order_Type]
    ON [AFISales_DW].[DimOrderHistoryDetails]([Secondary Order Type]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_Request_Date]
    ON [AFISales_DW].[DimOrderHistoryDetails]([Request Date]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_Primary_Order_Type]
    ON [AFISales_DW].[DimOrderHistoryDetails]([Primary Order Type]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_Order_Sequence]
    ON [AFISales_DW].[DimOrderHistoryDetails]([Order Sequence]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_Order_Arrival_Mode]
    ON [AFISales_DW].[DimOrderHistoryDetails]([Order Arrival Mode]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_4th_Order_Type]
    ON [AFISales_DW].[DimOrderHistoryDetails]([4th Order Type]);


GO
CREATE STATISTICS [Stat_DimOrderHistoryDetails_3rd_Order_Type]
    ON [AFISales_DW].[DimOrderHistoryDetails]([3rd Order Type]);

