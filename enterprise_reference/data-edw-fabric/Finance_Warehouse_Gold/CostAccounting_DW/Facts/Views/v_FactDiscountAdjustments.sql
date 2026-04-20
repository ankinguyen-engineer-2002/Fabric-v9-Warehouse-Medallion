CREATE VIEW [CostAccounting_DW_Wrk].[v_FactDiscountAdjustments] AS SELECT
[Invoice Number]			
,[Order Number]				
,[Item Number]				
,CAST([Item Sequence Number]	AS DECIMAL(7,0)) AS  [Item Sequence Number]	
,CAST([Invoice Date] As DATE) AS [Invoice Date]				
,[Discount Type]			
,[Discount Adjustment Code]
,[Amount]					
,[Adjustment Amount]		
,[WarehouseDetailsKey]		
,[DiscountAdjDetailsKey]	
,[ShippedHistoryDetailKey] 
,[ItemDetailKey]		   
,[CustomerDetailKey]	   
FROM
(SELECT			 [Invoice Number]			= FDCINVOICENUMBER
				,[Order Number]				= FDCORDERNUMBER
				,[Item Number]				= TRIM(FDCITEMNUMBER)
				,[Item Sequence Number]		= FDCITEMSEQUENCE
				,[Invoice Date]				= FDCINVOICEDATE
				,[Discount Type]			= FDCDISCOUNTTYPE
				,[Discount Adjustment Code]	= FDCDISCOUNTADJUSTMENTCODE
				,[Amount]					= FDCAMOUNT
				,[Adjustment Amount]		= FDCADJUSTMENTAMOUNT
				,[WarehouseDetailsKey]		= ISNULL(DW.[WarehouseDetailsKey],1)
				,[DiscountAdjDetailsKey]	= ISNULL(DAJ.[DiscountAdjDetailsKey],1)
				,[ShippedHistoryDetailKey]  = ISNULL(DS.[ShippedHistoryDetailKey],1)
				,[ItemDetailKey]		    = ISNULL(DI.[ItemDetailKey],0)	
				,[CustomerDetailKey]	    = ISNULL(DC.[CustomerDetailKey],0)
		FROM	[$(Databricks)].costaccounting.[fif244x] Sh 
		LEFT JOIN  [CostAccounting_DW].[DimDiscountAdjDetails] DAJ
		on(ISNULL(Sh.[FDCDISCOUNTTYPE],'')=ISNULL(DAJ.[Discount Type],'' ) and   
		ISNULL(Sh.[FDCDISCOUNTADJUSTMENTCODE],'') = ISNULL(DAJ.[Discount Adjustment Code],''))
		LEFT JOIN [$(Databricks)].costaccounting.[fif244] SHC
		        ON  SHC.SHCINVOICENUMBER= Sh.FDCINVOICENUMBER
				AND SHC.SHCORDERNUMBER =  Sh.FDCORDERNUMBER 
				AND SHC.SHCITEMNUMBER =   Sh.FDCITEMNUMBER 
				AND SHCITEMSEQUENCENUMBER = Sh.FDCITEMSEQUENCE
		LEFT JOIN [CostAccounting_DW].[DimShippedHistoryDetails] DS
				ON  Sh.FDCINVOICENUMBER = DS.[Invoice Number]
				AND Sh.FDCORDERNUMBER = DS.[Order Number]
				AND Sh.FDCITEMNUMBER = DS.[Item Number]
				AND Sh.FDCITEMSEQUENCE = DS.[Item Sequence Number]
	    LEFT  JOIN [CostAccounting_DW].[DimWarehouseDetails] DW
				ON SHC.SHCWAREHOUSE = DW.[Warehouse]
	    LEFT JOIN [CostAccounting_DW].[DimItemDetail] DI
				ON  TRIM(SHC.SHCWAREHOUSE) = DI.[Item Number]
				AND TRIM(SHC.SHCQUANTITYUNITOFMEASURE) = DI.[Quantity Unit of Measure]
				AND TRIM(SHC.SHCITEMCLASS) = DI.[Item Class]
			    AND TRIM(SHC.SHCITEMCLASSDESCRIPTION) = DI.[Item Class Description]
			    AND TRIM(SHC.SHCITEMDESCRIPTION) = DI.[Item Description]
			    AND TRIM(SHC.SHCITEMTYPE) = DI.[Item Type]
			    AND TRIM(SHC.SHCFINANCIALDIVISION) = DI.[Financial Division]
			    AND TRIM(SHC.SHCFINANCIALDIVISIONDESC) = DI.[Financial Division Description]
			    AND TRIM(SHC.SHCSALESDIVISION) = DI.[Sales Division]
			    AND TRIM(SHC.SHCSALESDIVISIONDESCRIPTION) = DI.[Sales Division Description]
			    AND TRIM(SHC.SHCFREIGHTSALESCLASS) = DI.[Freight Sales Class]
			    AND TRIM(SHC.SHCCOMMISSIONSALESCLASS) = DI.[Commission Sales Class]
			    AND TRIM(SHC.SHCSERIES) = DI.[Series]
			    AND TRIM(SHC.SHCDISCOUNTSALESCLASS) = DI.[Discount Sales Class]
			    AND TRIM(SHC.SHCMANUFACTURINGSTATUSCODE) = DI.[Manufacturing Status Code]
		LEFT JOIN [CostAccounting_DW].[DimCustomerDetails] DC
				ON  SHC.SHCCUSTOMERNUMBER = DC.[Customer Number]
				AND TRIM(SHC.SHCBILLTOSTATUS) =DC.[Bill To Status]
				AND TRIM(SHC.SHCSHIPTOSTATUS) =DC.[Ship To Status]
			    AND TRIM(SHC.SHCBUSINESSTYPE) =DC.[Business Type]
				AND TRIM(SHC.SHCHOMESTOREFLAG) =DC.[Homestore Flag]
				AND TRIM(SHC.SHCCUSTOMERTERMSDESCRIPTION) =DC.[Customer Terms Description]
				AND TRIM(SHC.SHCBILLTONAME) =DC.[Bill To Name]
				AND TRIM(SHC.SHCBILLTOADDRESS1) =DC.[Bill To Address 1]
				AND TRIM(SHC.SHCBILLTOADDRESS2) =DC.[Bill To Address 2]
				AND TRIM(SHC.SHCBILLTOCITY) =DC.[Bill To City]
				AND TRIM(SHC.SHCBILLTOSTATE) =DC.[Bill To State]
				AND TRIM(SHC.SHCBILLTOZIPCODE) =DC.[Bill To Zip Code]
				AND TRIM(SHC.SHCBILLTOCOUNTRY) =DC.[Bill To Country]
				AND TRIM(SHC.SHCSHIPTONUMBER) =DC.[Ship To Number]
				AND TRIM(SHC.SHCSHIPTONAME) =DC.[Ship To Name]
				AND REPLACE(LTRIM(RTRIM(SHC.SHCSHIPTOADDRESS1)),CHAR(9),'') =DC.[Ship To Address 1]
				AND REPLACE(LTRIM(RTRIM(SHC.SHCSHIPTOADDRESS2)),CHAR(9),'') =DC.[Ship To Address 2]
				AND REPLACE(LTRIM(RTRIM(SHC.SHCSHIPTOCITY)),CHAR(9),'') =DC.[Ship To City]
				AND TRIM(SHC.SHCSHIPTOSTATE) =DC.[Ship To State]
				AND TRIM(SHC.SHCSHIPTOZIPCODE) =DC.[Ship To Zip Code]
				AND TRIM(SHC.SHCSHIPTOCOUNTRY) =DC.[Ship To Country]
				AND TRIM(SHC.SHCCOMMISSIONCODE) =DC.[Commission Code]
				AND TRIM(SHC.SHCPRICECODE) =DC.[Price Code]
				AND TRIM(SHC.SHCFREIGHTCODE) =DC.[Freight Code]
				AND TRIM(SHC.SHCFREIGHTCODEDESCRIPTION) =DC.[Freigth Code Description]
				AND TRIM(SHC.SHCITEMDISCOUNTCODE) =DC.[Item Discount Code]
				AND TRIM(SHC.SHCDISCOUNTCODEDESCRIPTION) =DC.[Discount Code Description])A;
GO
