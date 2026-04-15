CREATE VIEW [SSAS_AFISALES_OLAP].[DimOrderHistoryDetails]
AS
    SELECT [Order Change Date]
      , [Order Number]
      , [Order Sequence]
      , [Request Date]
      , [Order Arrival Mode]
      , [Primary Order Type]
      , [Secondary Order Type]
      , [3rd Order Type]
      , [4th Order Type]
    FROM [AFISales_DW].[DimOrderHistoryDetails]
    WHERE [Order Change Date] >= GETDATE()-1095;