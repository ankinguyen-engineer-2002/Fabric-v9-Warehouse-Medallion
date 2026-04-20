
CREATE VIEW [Quality_AFI_Wrk].[v_ReplacementPartDetail]
AS
SELECT 
CAST([RPKEY] AS [numeric](7,0)) AS [RPKey],
CAST([ITMSEQ] AS [decimal](2,0)) AS [ItemSequence],
CAST([ITEMNO] AS [varchar](15)) AS [ItemSKU],
[ITEMFG] AS [ComponentOverrideFlag],
CAST([QTY] AS [decimal](4,0)) AS [Quantity],
CAST([STDCST] AS [decimal](6,2)) AS [StandardCost],
CAST([BASPRC] AS [decimal](6,2)) AS [BasePrice],
[SHPFLG] AS [ShippedFlag],
[PCKFLG] AS [PickFlag],
[PCKBAD] AS [PickBad],
CASE WHEN PCKDTE = '0.000000000000000000' THEN NULL ELSE CAST(CAST(CAST([PCKDTE] AS INT) AS VARCHAR(10)) AS DATE) END AS [PickDate],
CAST([PCKTME] AS [decimal](6,0)) AS [PickTime],
CAST([PCKUSR] AS [varchar](10)) AS [PickUser],
[ICRGTYP] AS [ChargeType],
CAST([ISHPCST] AS [decimal](6,2)) AS [ShippingCost]
FROM [$(Source_Data)].[Wholesale_Quality_AFI].[ARPDETL]
GO

