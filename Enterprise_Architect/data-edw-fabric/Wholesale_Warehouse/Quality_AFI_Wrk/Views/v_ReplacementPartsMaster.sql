
CREATE VIEW [Quality_AFI_Wrk].[v_ReplacementPartsMaster]
AS
SELECT
CAST([ropModel] AS [varchar](15)) AS [ItemSKU],
CAST([ropPart] AS [varchar](15)) AS [Part],
CAST([ropQtyUsed] AS [int]) AS [QtyUsed],
CAST([ropDesr] AS [varchar](40)) AS [Description],
CAST([ropBasePrice] AS [decimal](7,2)) AS [BasePrice],
[ropCallout] AS [Callout],
[ropSource] AS [Source],
[ropDescSrc] AS [DescSrc],
CAST([ropWarrantyException] AS [bit]) AS [WarrantyException],
CAST([usra] AS [varchar](30)) AS [AddedByUser],
CAST([dtea] AS [datetime2](6)) AS [DateAdded],
CAST([usrc] AS [varchar](30)) AS [ChangeByUser],
CAST([dtec] AS [datetime2](6)) AS [DateChange]
FROM [$(Source_Data)].[Wholesale_Quality_AFI].[ReplacementPartsMaster]
GO

