CREATE VIEW CostAccounting_DW_Wrk.v_DimMarginDetails AS

		SELECT	 
				 [MarginDetailsKey]					= cast('' as int)
				,[Fiscal Year Period]				= ''
				,[Item Number]						= ''
				,[Margin Warehouse]					= cast('' as char(3))
				,[Item Series]						= ''
				,[Series Description]				= ''
				,[Item Class]						= cast('' as char(4))
				,[Item Class Description]			= ''
				,[Item Description]					= ''
				,[Manufacturing Status Code]		= cast('' as char(1))
				,[Import Office]					= '' 
				,[Financial Division]				= cast('' as char(1))
				,[Financial Division Description]	= ''

		UNION

		SELECT
				 [MarginDetailsKey]					= CAST(ROW_NUMBER() OVER( ORDER BY (SELECT 1))  AS INT) 
				,[Fiscal Year Period]				= Convert(Varchar(4),CAST(a.GMCFISCALYEAR AS INT)) + Case When a.GMCFISCALMONTH < 10 then '0' else '' end + Convert(Varchar(2),CAST(a.GMCFISCALMONTH AS INT))
				,[Item Number]						= TRIM(a.GMCITEMNUMBER)
				,[Margin Warehouse]					= cast(a.GMCMARGINWAREHOUSE as char(3))
				,[Item Series]						= a.GMCSERIES
				,[Series Description]				= a.GMCSERIESDESCRIPTION
				,[Item Class]						= cast(a.GMCITEMCLASS as char(4))
				,[Item Class Description]			= a.GMCITEMCLASSDESCRIPTION
				,[Item Description]					= a.GMCITEMDESCRIPTION
				,[Manufacturing Status Code]		= cast(a.GMCMANUFACTURINGSTATUSCODE as char(1))
				,[Import Office]					= a.GMCIMPORTOFFICE 
				,[Financial Division]				= cast(a.GMCFINANCIALDIVISION as char(1))
				,[Financial Division Description]	= a.GMCFINANCIALDIVISIONDESC
		FROM	[$(Databricks)].costaccounting.[fif115] a 
