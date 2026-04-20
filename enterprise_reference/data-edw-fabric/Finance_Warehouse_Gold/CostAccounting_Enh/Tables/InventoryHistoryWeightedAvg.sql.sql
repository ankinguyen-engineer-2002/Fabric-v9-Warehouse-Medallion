CREATE TABLE [CostAccounting_Enh].[InventoryHistoryWeightedAvg] (
    [ikey] VARCHAR (20) NULL,
    [ActDATE] DATETIME2 (6) NULL,
    [Activity] VARCHAR (20) NULL,
    [adj_qty] INT NULL,
    [balance] REAL NULL,
    [Rownumber] INT NULL,
    [OnHand] INT NULL,
    [Adj_Unit_Cost] REAL NULL,
    [In_His_Lst_Cost] REAL NULL,
    [In_His_Lst_Lnd_Cost] REAL NULL,
    [WeightedAvg] REAL NULL
)
   -- WITH (
   -- DATA_SOURCE = [AzureStorageGen2a_raw],
    --LOCATION = N'/CostAccounting/InventoryWeightedAvg/',
   -- FILE_FORMAT = [ParquetFileFormatSnappy],
   -- REJECT_TYPE = VALUE,
    --REJECT_VALUE = 0
    --);

