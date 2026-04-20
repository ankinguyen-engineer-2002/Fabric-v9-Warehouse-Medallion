CREATE VIEW Customers_Wrk.v_CustomerCredit
AS
SELECT 
CAST([Cuscusnbr] AS [decimal](8,0)) AS [CustomerNumber],
CAST([Cuscrdlmt] AS [decimal](8,0)) AS [CreditLimit],
CAST([Cusavedy1] AS [decimal](4,0)) AS [BeyondTerms_90Days],
CAST([Cusavedy2] AS [decimal](4,0)) AS [BeyondTerms_6Months],
CAST([Cusavedy3] AS [decimal](4,0)) AS [BeyondTerms_365Days],
CAST([Cusavedy4] AS [decimal](4,0)) AS [BeyondTerms_Life],
CAST([Cusavedy5] AS [decimal](4,0)) AS [BeyondTerms_Custom],
CAST([Cushicred] AS [decimal](38,2)) AS [HighestCredit],
CAST([Cusratamt] AS [decimal](38,2)) AS [OutstandingBalance],
CAST([Cusua01] AS [decimal](38,4)) AS [ACI_Amount]
FROM  [$(Source_Data)].[Wholesale_Codis_AFI].[MC2CUEPF]
GO

