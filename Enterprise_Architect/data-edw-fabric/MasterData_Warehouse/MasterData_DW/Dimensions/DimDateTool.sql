CREATE TABLE [MasterData_DW].[DimDateTool] (
    [DateToolID]    VARCHAR (7)  NULL,
    [AggregationID] INT      NULL,
    [Aggregation]   VARCHAR (50) NULL,
    [ComparisonID]  INT      NULL,
    [Comparison]    VARCHAR (50) NULL
)

GO
CREATE STATISTICS [Stat_DimDateTool_DateToolID]
    ON [MasterData_DW].[DimDateTool]([DateToolID]);


GO
CREATE STATISTICS [Stat_DimDateTool_ComparisonID]
    ON [MasterData_DW].[DimDateTool]([ComparisonID]);


GO
CREATE STATISTICS [Stat_DimDateTool_Comparison]
    ON [MasterData_DW].[DimDateTool]([Comparison]);


GO
CREATE STATISTICS [Stat_DimDateTool_AggregationID]
    ON [MasterData_DW].[DimDateTool]([AggregationID]);


GO
CREATE STATISTICS [Stat_DimDateTool_Aggregation]
    ON [MasterData_DW].[DimDateTool]([Aggregation]);

