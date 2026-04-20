CREATE VIEW [CostAccounting_DW_Wrk].[v_DimWarehouseDetails]
AS 
SELECT 
CAST(ROW_NUMBER() OVER (ORDER BY
                                    Warehouse
                               ) AS BIGINT) WarehouseDetailsKey,
 [Warehouse],
 [Margin Warehouse]

 FROM 
 (
SELECT 	     [Warehouse]			= ''
				,[Margin Warehouse]		= ''
	UNION ALL

		SELECT DISTINCT  
				         [Warehouse]			= TRIM(SHCWAREHOUSE)
						,[Margin Warehouse]		= TRIM(SHCMARGINWAREHOUSE)

		FROM	[$(Databricks)].costaccounting.[fif244] SHCd
 ) WH

