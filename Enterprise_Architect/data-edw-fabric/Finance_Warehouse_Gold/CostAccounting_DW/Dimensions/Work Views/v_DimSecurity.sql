CREATE VIEW [CostAccounting_DW_Wrk].[v_DimSecurity] AS SELECT 
CAST([Security Tag] AS CHAR(4)) AS [Security Tag]
FROM
(
SELECT	[Security Tag]	= 'Base'
		UNION
		SELECT	[Security Tag]	= 'Cost'
		UNION
		SELECT	[Security Tag]	= 'Mrgn'
) A;
