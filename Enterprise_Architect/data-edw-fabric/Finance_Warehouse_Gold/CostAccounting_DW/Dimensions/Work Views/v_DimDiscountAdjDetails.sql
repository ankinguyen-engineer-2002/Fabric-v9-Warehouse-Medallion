CREATE VIEW CostAccounting_DW_Wrk.v_DimDiscountAdjDetails AS

		SELECT 	 [DiscountAdjDetailsKey]		= 1
				,[Discount Type]				= ''
				,[Discount Adjustment Code]		= ''

		UNION

		SELECT
		IsNull(b.[DiscountAdjDetailsKey],Isnull((SELECT MAX([DiscountAdjDetailsKey]) FROM [CostAccounting_DW].[DimDiscountAdjDetails] ),1)+ROW_NUMBER() OVER (ORDER BY (SELECT b.[DiscountAdjDetailsKey] isnull))) AS [DiscountAdjDetailsKey]
		  --IsNull(b.[DiscountAdjDetailsKey],@MaxSurrogateKey+ROW_NUMBER() OVER (ORDER BY (SELECT b.[DiscountAdjDetailsKey] isnull))) AS [DiscountAdjDetailsKey]
		--[DiscountAdjDetailsKey]		= 1 + ROW_NUMBER() OVER (ORDER BY [Discount Type], [Discount Adjustment Code])
				,[Discount Type]				= a.[Discount Type]
				,[Discount Adjustment Code]		= a.[Discount Adjustment Code]
		FROM	
				(SELECT  [Discount Type]				= FDCDISCOUNTTYPE
						,[Discount Adjustment Code]		= FDCDISCOUNTADJUSTMENTCODE
				FROM	[$(Databricks)].costaccounting.[fif244x]

				UNION

				SELECT 	 [Discount Type]				= FDSDiscountType
						,[Discount Adjustment Code]		= FDSDiscountAdjustmentCode
				FROM	[CostAccounting_Enh].[ShippedHistoryCubeDataStatic_Discounts]) a
				LEFT JOIN [CostAccounting_DW].[DimDiscountAdjDetails] b
				on(a.[Discount Type]=b.[Discount Type] and a.[Discount Adjustment Code]=b.[Discount Adjustment Code]	)


 