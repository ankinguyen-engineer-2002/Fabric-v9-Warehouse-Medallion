CREATE VIEW CostAccounting_DW_Wrk.v_FactShippedHistoryDetail AS
SELECT	 [Invoice Number]						    = SHCINVOICENUMBER
				,[Order Number]							= SHCORDERNUMBER
				,[Item Number]							= TRIM(SHCITEMNUMBER)
				,[Item Sequence Number]					= cast(SHCITEMSEQUENCENUMBER as decimal(7,0))
				,[Invoice Date]							= cast(SHCINVOICEDATE as date)
				,[Fiscal Year Period]					= SHCFISCALYEARPERIOD
				,[Margin Warehouse]						= SHCMARGINWAREHOUSE
				,[Gross Quantity Shipped]				= CASE WHEN SHCGROSSQUANTITYSHIPPED <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335') THEN SHCGROSSQUANTITYSHIPPED ELSE NULL END
				,[Gross Amount Shipped]					= CASE WHEN SHCGROSSAMOUNTSHIPPED <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335') THEN SHCGROSSAMOUNTSHIPPED ELSE NULL END
				,[Return Quantity]						= CASE WHEN SHCRETURNQUANTITY <> 0 THEN SHCRETURNQUANTITY ELSE NULL END
				,[Return Amount]						= CASE WHEN SHCRETURNAMOUNT <> 0 THEN SHCRETURNAMOUNT ELSE NULL END
				,[Short Ship Quantity]					= CASE WHEN SHCSHORTSHIPQUANTITY <> 0 THEN SHCSHORTSHIPQUANTITY ELSE NULL END
				,[Short Ship Amount]					= CASE WHEN SHCSHORTSHIPAMOUNT <> 0 THEN SHCSHORTSHIPAMOUNT ELSE NULL END
				,[Quality Credit Amount]				= CASE WHEN SHCQUALITYCREDITAMOUNT <> 0 THEN SHCQUALITYCREDITAMOUNT ELSE NULL END
				,[Net Quantity Shipped]					= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCNETQUANTITYSHIPPED ELSE NULL END
				,[Net Amount Shipped]					= CASE WHEN SHCNETAMOUNTSHIPPED <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCNETAMOUNTSHIPPED ELSE NULL END
				,[Ext Selling Price]					= CASE WHEN SHCEXTSELLINGPRICE <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTSELLINGPRICE ELSE NULL END
				,[Ext Price Exception Amount]			= CASE WHEN SHCEXTPRICEEXCEPTIONAMOUNT <> 0 THEN SHCEXTPRICEEXCEPTIONAMOUNT ELSE NULL END
				,[Ext Line Item Freight]				= CASE WHEN SHCEXTLINEITEMFREIGHT <> 0 THEN SHCEXTLINEITEMFREIGHT ELSE NULL END
				,[Ext Line Item Discounts]				= CASE WHEN SHCEXTLINEITEMDISCOUNTS <> 0 THEN SHCEXTLINEITEMDISCOUNTS ELSE NULL END
				,[Ext Advertising Accrual]				= CASE WHEN SHCEXTADVERTISINGACCRUAL <> 0 THEN SHCEXTADVERTISINGACCRUAL ELSE NULL END
				,[Ext DFI Discounts]					= CASE WHEN SHCEXTDFIDISCOUNTS <> 0 THEN SHCEXTDFIDISCOUNTS ELSE NULL END
				,[Ext Contract Price]					= CASE WHEN SHCEXTCONTRACTPRICE <> 0 and NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTCONTRACTPRICE ELSE NULL END
				,[Invoice Tax Amount]					= CASE WHEN SHCINVOICETAXAMOUNT <> 0 THEN SHCINVOICETAXAMOUNT ELSE NULL END
				,[Ext Comm Adj - Freight]				= CASE WHEN SHCEXTCOMMADJ_FREIGHT <> 0 THEN SHCEXTCOMMADJ_FREIGHT ELSE NULL END
				,[Ext Comm Adj - Gross]					= CASE WHEN SHCEXTCOMMADJ_GROSS <> 0 THEN SHCEXTCOMMADJ_GROSS ELSE NULL END
				,[Ext Comm Adj - Warranty]				= CASE WHEN SHCEXTCOMMADJ_WARRANTY <> 0 THEN SHCEXTCOMMADJ_WARRANTY ELSE NULL END
				,[Ext FOB at Order Time]				= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 And SHCEXTFOB_ORDERTIME <> 0 and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335')  THEN SHCEXTFOB_ORDERTIME ELSE NULL END
				,[Ext FOB at Invoice Time]				= CASE WHEN SHCNETQUANTITYSHIPPED <> 0 And SHCEXTFOB_INVOICETIME <> 0  and  NOT (DC.[Customer Number]='3824800' and DW.[Warehouse]='335') THEN SHCEXTFOB_INVOICETIME ELSE NULL END
				,[Special Charge Amount]				= CASE WHEN SHCSPECIALCHARGEAMOUNT <> 0 THEN SHCSPECIALCHARGEAMOUNT ELSE NULL END
				,[Bonded Warehouse Transfer Quantity] 	= CASE WHEN DC.[Customer Number]='3824800' and DW.[Warehouse]='335' THEN e.SHCGROSSQUANTITYSHIPPED ELSE NULL END  
			    ,[Bonded Warehouse Transfer Amount]		= CASE WHEN DC.[Customer Number]='3824800' and DW.[Warehouse]='335' THEN e.SHCGROSSAMOUNTSHIPPED ELSE NULL END
			    ,[Special Charge Freight]				= CASE WHEN DS.[Special Charge Code]=1 then SHCSPECIALCHARGEAMOUNT ELSE NULL END
			    ,[Special Charge Non-Freight]			= CASE WHEN DS.[Special Charge Code]<>1 then SHCSPECIALCHARGEAMOUNT ELSE NULL END
			    ,[Special Charge Discounts]				= CASE WHEN DS.[Special Charge Code]<>1 and DS.[Special Charge Type Code]='D' then SHCSPECIALCHARGEAMOUNT ELSE NULL END
			    ,[Special Charge Non-Discounts]			= CASE WHEN DS.[Special Charge Code]<>1 and DS.[Special Charge Type Code]<>'D' then SHCSPECIALCHARGEAMOUNT ELSE NULL END
			    ,[WarehouseDetailsKey]					= ISNULL(DW.[WarehouseDetailsKey],1)
				,[MarginDetailsKey]						= ISNULL(DM.[MarginDetailsKey],1)
				,[ShippedHistoryDetailKey]				= ISNULL(DS.[ShippedHistoryDetailKey],1)
				,[ItemDetailKey]						= ISNULL(DI.[ItemDetailKey],1)	
				,[CustomerDetailKey]					= ISNULL(DC.[CustomerDetailKey],1)
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
	LEFT JOIN [CostAccounting_DW].[DimWarehouseDetails] DW
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
				ON  e.SHCCUSTOMERNUMBER = DC.[Customer Number]
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
				AND REPLACE(LTRIM(RTRIM(e.SHCBILLTOADDRESS1)),CHAR(9),'') =DC.[Ship To Address 1]
				AND REPLACE(LTRIM(RTRIM(e.SHCBILLTOADDRESS2)),CHAR(9),'') =DC.[Ship To Address 2]
				AND REPLACE(LTRIM(RTRIM(e.SHCSHIPTOCITY)),CHAR(9),'') =DC.[Ship To City]
				AND TRIM(e.SHCBILLTOSTATE) =DC.[Ship To State]
				AND TRIM(e.SHCBILLTOZIPCODE) =DC.[Ship To Zip Code]
				AND TRIM(e.SHCBILLTOCOUNTRY) =DC.[Ship To Country]
				AND TRIM(e.SHCCOMMISSIONCODE) =DC.[Commission Code]
				AND TRIM(e.SHCPRICECODE) =DC.[Price Code]
				AND TRIM(e.SHCFREIGHTCODE) =DC.[Freight Code]
				AND TRIM(e.SHCFREIGHTCODEDESCRIPTION) =DC.[Freigth Code Description]
				AND TRIM(e.SHCFREIGHTCODEDESCRIPTION) =DC.[Item Discount Code]
				AND TRIM(e.SHCDISCOUNTCODEDESCRIPTION) =DC.[Discount Code Description]
	
	
