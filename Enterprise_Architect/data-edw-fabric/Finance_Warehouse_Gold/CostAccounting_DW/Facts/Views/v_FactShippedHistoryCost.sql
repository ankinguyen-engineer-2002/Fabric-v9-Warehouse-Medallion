CREATE VIEW [CostAccounting_DW_Wrk].[v_FactShippedHistoryCost]
AS SELECT	 [Invoice Number]					= SHCINVOICENUMBER
				,[Order Number]						= SHCORDERNUMBER
				,[Item Number]						= TRIM(SHCITEMNUMBER)
				,[Item Sequence Number]				= SHCITEMSEQUENCENUMBER
				,[Invoice Date]						= SHCINVOICEDATE	
				,[Fiscal Year Period]				= SHCFISCALYEARPERIOD
				,[Margin Warehouse]					= SHCMARGINWAREHOUSE
				,[Security Tag]						= 'Cost'
				,[Ext Standard Unit Cost]			= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCNETQUANTITYSHIPPED <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTSTANDARDUNITCOST ELSE NULL END
				,[Ext Import Vendor Price]			= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTIMPORTVENDORPRICE <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTIMPORTVENDORPRICE ELSE NULL END
				,[Ext Import Vendor Overhead]		= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTIMPORTVENDOROVERHEAD <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTIMPORTVENDOROVERHEAD ELSE NULL END
				,[Ext Material Cost]				= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTMATERIALCOST <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTMATERIALCOST ELSE NULL END
				,[Ext Freight Cost]					= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTFREIGHTCOST <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTFREIGHTCOST ELSE NULL END
				,[Ext Labor Cost]					= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTLABORCOST <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335') THEN SHCEXTLABORCOST ELSE NULL END
				,[Ext Labor Overhead Cost]			= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTLABOROVERHEADCOST <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTLABOROVERHEADCOST ELSE NULL END
				,[Ext Material Overhead Cost]		= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTMATERIALOVERHEADCOST <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTMATERIALOVERHEADCOST ELSE NULL END
				,[Ext AFT Import Vendor Markup]		= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTAFTIMPORTVENDORMARKUP <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTAFTIMPORTVENDORMARKUP ELSE NULL END
				,[Ext AFT Markup]					= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTAFTMARKUP <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTAFTMARKUP ELSE NULL END
			    ,[Bonded Warehouse Transfer Cost]	= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 AND SHCEXTIMPORTVENDORPRICE <> 0 and  DC.[Customer Number]='3824800' and DW.[Warehouse]='335'  THEN SHCEXTIMPORTVENDORPRICE ELSE NULL END
				,[WarehouseDetailsKey]				= ISNULL(DW.[WarehouseDetailsKey],1)
				,[MarginDetailsKey]					= ISNULL(DM.[MarginDetailsKey],1)
				,[ShippedHistoryDetailKey]			= ISNULL(DS.[ShippedHistoryDetailKey],1)
				,[ItemDetailKey]					= ISNULL(DI.[ItemDetailKey],0)	
				,[CustomerDetailKey]				= ISNULL(DC.[CustomerDetailKey],0)
		FROM	[$(Databricks)].costaccounting.[fif244] e
		LEFT JOIN [CostAccounting_DW].[DimMarginDetails] DM
				ON e.SHCFISCALYEARPERIOD = DM.[Fiscal Year Period]
				AND e.SHCMARGINWAREHOUSE = DM.[Margin Warehouse]
				AND e.SHCITEMNUMBER = DM.[Item Number]
       LEFT JOIN [CostAccounting_DW].[DimShippedHistoryDetails] DS
				ON  e.SHCINVOICENUMBER = DS.[Invoice Number]
				AND e.SHCORDERNUMBER = DS.[Order Number]
				AND e.SHCITEMNUMBER = DS.[Item Number]
				AND e.SHCITEMSEQUENCENUMBER = DS.[Item Sequence Number]
	   LEFT  JOIN [CostAccounting_DW].[DimWarehouseDetails] DW
				ON e.SHCWAREHOUSE = DW.[Warehouse]
	   LEFT JOIN [CostAccounting_DW].[DimItemDetail] DI
				ON  TRIM(e.SHCITEMNUMBER) = DI.[Item Number]
				AND TRIM(e.SHCQUANTITYUNITOFMEASURE) = DI.[Quantity Unit of Measure]
				AND TRIM(e.SHCITEMCLASS) = DI.[Item Class]
			    AND TRIM(e.SHCITEMCLASSDESCRIPTION) = DI.[Item Class Description]
			    AND TRIM(e.SHCITEMDESCRIPTION) = DI.[Item Description]
			    AND TRIM(e.SHCITEMTYPE) = DI.[Item Type]
			    AND TRIM(e.SHCFINANCIALDIVISION) = DI.[Financial Division]
			    AND TRIM(e.SHCFINANCIALDIVISIONDESC) = DI.[Financial Division Description]
			    AND TRIM(e.SHCSALESDIVISION) = DI.[Sales Division]
			    AND TRIM(e.SHCSALESDIVISIONDESCRIPTION) = DI.[Sales Division Description]
			    AND TRIM(e.SHCFREIGHTSALESCLASS) = DI.[Freight Sales Class]
			    AND TRIM(e.SHCCOMMISSIONSALESCLASS) = DI.[Commission Sales Class]
			    AND TRIM(e.SHCSERIES) = DI.[Series]
			    AND TRIM(e.SHCDISCOUNTSALESCLASS) = DI.[Discount Sales Class]
			    AND TRIM(e.SHCMANUFACTURINGSTATUSCODE) = DI.[Manufacturing Status Code]
		LEFT JOIN [CostAccounting_DW].[DimCustomerDetails] DC
				ON  e.SHCCUSTOMERNUMBER= DC.[Customer Number]
				AND TRIM(e.SHCSHIPTONUMBER)= DC.[Ship To Number]							 
				AND TRIM(e.SHCBILLTOSTATUS) =DC.[Bill To Status]
				AND TRIM(e.SHCSHIPTOSTATUS) =DC.[Ship To Status]
			    AND TRIM(e.SHCBUSINESSTYPE) =DC.[Business Type]
				AND TRIM(e.SHCHOMESTOREFLAG) =DC.[Homestore Flag]
				AND TRIM(e.SHCCUSTOMERTERMSDESCRIPTION) =DC.[Customer Terms Description]
				AND TRIM(e.SHCBILLTONAME) =DC.[Bill To Name]
				AND TRIM(e.SHCBILLTOADDRESS1) =DC.[Bill To Address 1]
				AND TRIM(e.SHCBILLTOADDRESS2) =DC.[Bill To Address 2]
				AND TRIM(e.SHCBILLTOCITY) =DC.[Bill To City]
				AND TRIM(e.SHCBILLTOSTATE) =DC.[Bill To State]
				AND TRIM(e.SHCBILLTOZIPCODE) =DC.[Bill To Zip Code]
				AND TRIM(e.SHCBILLTOCOUNTRY) =DC.[Bill To Country]
				AND TRIM(e.SHCSHIPTONAME) =DC.[Ship To Name]
				AND REPLACE(LTRIM(RTRIM(e.SHCSHIPTOADDRESS1)),CHAR(9),'') =DC.[Ship To Address 1]
				AND REPLACE(LTRIM(RTRIM(e.SHCSHIPTOADDRESS2)),CHAR(9),'') =DC.[Ship To Address 2]
				AND REPLACE(LTRIM(RTRIM(e.SHCSHIPTOCITY)),CHAR(9),'') =DC.[Ship To City]
				AND TRIM(e.SHCSHIPTOSTATE) =DC.[Ship To State]
				AND TRIM(e.SHCSHIPTOZIPCODE) =DC.[Ship To Zip Code]
				AND TRIM(e.SHCSHIPTOCOUNTRY) =DC.[Ship To Country]
				AND TRIM(e.SHCCOMMISSIONCODE) =DC.[Commission Code]
				AND TRIM(e.SHCPRICECODE) =DC.[Price Code]
				AND TRIM(e.SHCFREIGHTCODE) =DC.[Freight Code]
				AND TRIM(e.SHCFREIGHTCODEDESCRIPTION) =DC.[Freigth Code Description]
				AND TRIM(e.SHCITEMDISCOUNTCODE) =DC.[Item Discount Code]
				AND TRIM(e.SHCDISCOUNTCODEDESCRIPTION) =DC.[Discount Code Description];
GO


