CREATE VIEW [CostAccounting_DW_Wrk].[v_DimShippedHistoryDetails] AS 
WITH
	DimShippedHistoryDetails_LOAD2 AS
	(
		

		
		SELECT	 [Invoice Number]							= 0
				,[Invoice Date]								= '1900-01-01'
				,[Order Number]								= ''
				,[Item Number]							    = ''
				,[Item Sequence Number]						= 0
				,[Order Date]								= '1900-01-01'
				,[Credit Code]								= ''
				,[Special Promotion]						= ''
				,[Customer PO Number]						= ''
				,[Trip Number]								= 0
				,[Drop Number]								= 0
				,[Order Type 1]								= ''
				,[Order Type 2]								= ''
				,[Order Type 3]								= ''
				,[Order Type 4]								= ''
				,[Bill To Marketing Specialist]				= 0
				,[Bill To Commission Rate]					= 0
				,[Ship To Marketing Specialist]				= 0
				,[Ship To Commission Rate]					= 0
				,[Price Exception Record ID]				= 0
				,[Volume Percent]							= 0
				,[DFI Percent]								= 0
				,[Co-Op Ad Allowance Percent]				= 0
				,[No Show Discount Percent]					= 0
				,[Price Adder Percent]						= 0
				,[Exception Volume Percent]					= 0
				,[Exception DFI Percent]					= 0
				,[Exception Co-Op Ad Allowance Percent]		= 0
				,[Exception No Show Discount Percent]		= 0
				,[Exception Price Adder Percent]			= 0
				,[Special Charge Code]						= 0
				,[Special Charge Description]				= ''
				,[Special Charge Credit Code]				= ''
				,[Special Charge Credit Code Description]	= ''
				,[Special Charge Type Code]					= ''
				,[Defect Code]								= ''
				,[Location Code]							= ''
				,[Invoice Type]								= ''
UNION ALL
	

		SELECT	DISTINCT
			     [Invoice Number]							= FIF244.SHCINVOICENUMBER 
				,[Invoice Date]							    = SHCINVOICEDATE	
				,[Order Number]								= TRIM(FIF244.SHCORDERNUMBER) 
				,[Item Number]								= TRIM(FIF244.SHCITEMNUMBER)
				,[Item Sequence Number]						= FIF244.SHCITEMSEQUENCENUMBER 
				,[Order Date]								= FIF244.SHCORDERDATE  
				,[Credit Code]								= TRIM(FIF244.SHCCREDITCODE)  
				,[Special Promotion]						= REPLACE(LTRIM(RTRIM(FIF244.SHCSPECIALPROMOTION)),CHAR(9),'')
				,[Customer PO Number]						= TRIM(FIF244.SHCCUSTOMERPONUMBER)  
				,[Trip Number]								= FIF244.SHCTRIPNUMBER  
				,[Drop Number]								= FIF244.SHCDROPNUMBER  
				,[Order Type 1]								= TRIM(FIF244.SHCORDERTYPE1)  
				,[Order Type 2]								= TRIM(FIF244.SHCORDERTYPE2)  
				,[Order Type 3]								= TRIM(FIF244.SHCORDERTYPE3)  
				,[Order Type 4]								= TRIM(FIF244.SHCORDERTYPE4) 
				,[Bill To Marketing Specialist]				= FIF244.SHCBILLTOMARKETINGSPECIALIST  
				,[Bill To Commission Rate]					= FIF244.SHCBILLTOCOMMISSIONRATE  
				,[Ship To Marketing Specialist]				= FIF244.SHCSHIPTOMARKETINGSPECIALIST 
				,[Ship To Commission Rate]					= FIF244.SHCSHIPTOCOMMISSIONRATE  
				,[Price Exception Record ID]				= FIF244.SHCPRICEEXCEPTIONRECORDID  
				,[Volume Percent]							= FIF244.SHCVOLUMEPERCENT 
				,[DFI Percent]								= FIF244.SHCDFIPERCENT  
				,[Co-Op Ad Allowance Percent]				= FIF244.SHCCOOPADALLOWANCEPERCENT 
				,[No Show Discount Percent]					= FIF244.SHCNOSHOWDISCOUNTPERCENT  
				,[Price Adder Percent]						= FIF244.SHCPRICEADDERPERCENT  
				,[Exception Volume Percent]					= FIF244.SHCEXCEPTVOLUMEPERCENT 
				,[Exception DFI Percent]					= FIF244.SHCEXCEPTDFIPERCENT  
				,[Exception Co-Op Ad Allowance Percent]		= FIF244.SHCEXCEPTCOOPADALLOWPERCENT  
				,[Exception No Show Discount Percent]		= FIF244.SHCEXCEPTNOSHOWDISCPERCENT  
				,[Exception Price Adder Percent]			= FIF244.SHCEXCEPTPRICEADDERPERCENT  
				,[Special Charge Code]						= FIF244.SHCSPECIALCHARGECODE 
				,[Special Charge Description]				= TRIM(FIF244.SHCSPECIALCHARGEDESCRIPTION)  
				,[Special Charge Credit Code]				= TRIM(FIF244.SHCSPECIALCHARGECREDITCODE)  
				,[Special Charge Credit Code Description]	= TRIM(FIF244.SHCSPECIALCHARGECREDITCODEDESC)
				,[Special Charge Type Code]                 = TRIM(ACRDMAS.Crcde)
				,[Defect Code]								= TRIM(FIF244.SHCDEFECTCODE)  
				,[Location Code]							= TRIM(FIF244.SHCLOCATIONCODE)
				,[Invoice Type]								= CASE WHEN FIF244.SHCINVOICENUMBER < 100000 THEN 'Invoice' ELSE 'Credit' END
				
		FROM	[$(Databricks)].costaccounting.fif244 FIF244 
		LEFT JOIN [$(Source_Data)].[Wholesale_Codis_AFI].[ACRDMAS] ACRDMAS
		 ON ACRDMAS.Crcde=FIF244.[SHCSPECIALCHARGECREDITCODE]
  )

		
SELECT 
       [ShippedHistoryDetailKey]							= CAST(ROW_NUMBER() OVER( ORDER BY (SELECT 1))  AS Bigint) 
			,[Invoice Number]
			,[Invoice Date]	
			,[Order Number]
			,[Item Number]
			,[Item Sequence Number]
			,[Order Date]
			,[Credit Code]
			,Cast([Special Promotion] as varchar(25)) [Special Promotion]
			,Cast([Customer PO Number] as varchar(22)) [Customer PO Number]
			,[Trip Number]
			,[Drop Number]
			,[Order Type 1]
			,[Order Type 2]
			,[Order Type 3]
			,[Order Type 4]
			,[Bill To Marketing Specialist]
			,[Bill To Commission Rate]
			,[Ship To Marketing Specialist]
			,[Ship To Commission Rate]
			,[Price Exception Record ID]
			,[Volume Percent]
			,[DFI Percent]
			,[Co-Op Ad Allowance Percent]
			,[No Show Discount Percent]
			,[Price Adder Percent]
			,[Exception Volume Percent]
			,[Exception DFI Percent]
			,[Exception Co-Op Ad Allowance Percent]
			,[Exception No Show Discount Percent]
			,[Exception Price Adder Percent]
			,[Special Charge Code]
			,cast([Special Charge Description] as varchar(30)) [Special Charge Description]
			,[Special Charge Credit Code]
			,[Special Charge Credit Code Description]
			,[Special Charge Type Code]
			,[Defect Code]
			,[Location Code]
			,[Invoice Type]
FROM [DimShippedHistoryDetails_LOAD2]
	
	