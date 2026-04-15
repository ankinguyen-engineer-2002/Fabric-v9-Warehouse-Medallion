Create view Quality_DW_Wrk.v_FactCalculatedColumns
as
with ItemDescriptions
as
(

SELECT DISTINCT 
    RTRIM(LTRIM(itm.item_sku)) AS [Item No.],
    itm.series_no AS [Series No.],
    itm.item_name AS [AS400 Description],
	gd.GDCODE AS [Description Code],
	gd.GDICL AS [General Description],
	ml.mktCode AS [Introduction Market],
    itm.itmStatus AS [Status],
	fdi.fdiDescription AS [Financial Division],
	itm.itmImportDomestic AS [Import/Domestic],
    itm.itmQtyInBox AS [Qty in Box],
	itd.itdUnitOfMeasure AS [Unit Of Measure],
	itd.itdWidthIn AS [PK_Product_Width],
	itd.itdDepthIn AS [PK_Product_Depth],
	itd.itdHeightIn AS [PK_Product_Height],
	itd.itdWidthCartonIn AS [PK_Width],
	itd.itdDepthCartonIn AS [PK_Depth],
	itd.itdHeightCartonIn AS [PK_Height],
	itd.itdDimConfirmed AS [PK Dimensions Confirmed],
	CASE 
		WHEN itd.itdUnitOfMeasure = 'EA' THEN itd.itdWeight * itm.itmQtyInBox
		ELSE itd.itdWeight
	END AS [Weight],
	CASE 
		WHEN itd.itdWidthCartonIn >= itd.itdHeightCartonIn AND itd.itdWidthCartonIn >= itd.itdDepthCartonIn THEN ROUND(itd.itdWidthCartonIn, 0)
		WHEN itd.itdHeightCartonIn >= itd.itdWidthCartonIn AND itd.itdHeightCartonIn >= itd.itdDepthCartonIn THEN ROUND(itd.itdHeightCartonIn, 0)
		WHEN itd.itdDepthCartonIn >= itd.itdWidthCartonIn AND itd.itdDepthCartonIn >= itd.itdHeightCartonIn THEN ROUND(itd.itdDepthCartonIn, 0)
	END AS [Calc_Length],
	CASE 
		WHEN (itd.itdWidthCartonIn >= itd.itdHeightCartonIn AND itd.itdHeightCartonIn >= itd.itdDepthCartonIn) OR (itd.itdDepthCartonIn >= itd.itdHeightCartonIn AND itd.itdHeightCartonIn >= itd.itdWidthCartonIn) THEN ROUND(itd.itdHeightCartonIn, 0)
		WHEN (itd.itdHeightCartonIn >= itd.itdWidthCartonIn AND itd.itdWidthCartonIn >= itd.itdDepthCartonIn) OR (itd.itdDepthCartonIn >= itd.itdWidthCartonIn AND itd.itdWidthCartonIn >= itd.itdHeightCartonIn) THEN ROUND(itd.itdWidthCartonIn, 0)
		WHEN (itd.itdWidthCartonIn >= itd.itdDepthCartonIn AND itd.itdDepthCartonIn >= itd.itdHeightCartonIn) OR (itd.itdHeightCartonIn >= itd.itdDepthCartonIn AND itd.itdDepthCartonIn >= itd.itdWidthCartonIn) THEN ROUND(itd.itdDepthCartonIn, 0)
	END AS [Calc_Width],
	CASE 
		WHEN itd.itdWidthCartonIn <= itd.itdHeightCartonIn AND itd.itdWidthCartonIn <= itd.itdDepthCartonIn THEN ROUND(itd.itdWidthCartonIn, 0)
		WHEN itd.itdHeightCartonIn <= itd.itdWidthCartonIn AND itd.itdHeightCartonIn <= itd.itdDepthCartonIn THEN ROUND(itd.itdHeightCartonIn, 0)
		WHEN itd.itdDepthCartonIn <= itd.itdWidthCartonIn AND itd.itdDepthCartonIn <= itd.itdHeightCartonIn THEN ROUND(itd.itdDepthCartonIn, 0)
	END AS [Calc_Height],
	(2 * (ROUND(itd.itdWidthCartonIn, 0) + ROUND(itd.itdHeightCartonIn, 0) + ROUND(itd.itdDepthCartonIn, 0)) - CASE 
		WHEN itd.itdWidthCartonIn >= itd.itdHeightCartonIn AND itd.itdWidthCartonIn >= itd.itdDepthCartonIn THEN ROUND(itd.itdWidthCartonIn, 0)
		WHEN itd.itdHeightCartonIn >= itd.itdWidthCartonIn AND itd.itdHeightCartonIn >= itd.itdDepthCartonIn THEN ROUND(itd.itdHeightCartonIn, 0)
		WHEN itd.itdDepthCartonIn >= itd.itdWidthCartonIn AND itd.itdDepthCartonIn >= itd.itdHeightCartonIn THEN ROUND(itd.itdDepthCartonIn, 0)
	END) AS [Length + Girth],
	CASE 
		WHEN itd.itdWidthCartonIn >= itd.itdHeightCartonIn AND itd.itdWidthCartonIn >= itd.itdDepthCartonIn THEN ROUND(itd.itdWidthCartonIn+1, 0)
		WHEN itd.itdHeightCartonIn >= itd.itdWidthCartonIn AND itd.itdHeightCartonIn >= itd.itdDepthCartonIn THEN ROUND(itd.itdHeightCartonIn+1, 0)
		WHEN itd.itdDepthCartonIn >= itd.itdWidthCartonIn AND itd.itdDepthCartonIn >= itd.itdHeightCartonIn THEN ROUND(itd.itdDepthCartonIn+1, 0)
	END AS [Calc_Length_vboard],
	CASE 
		WHEN (itd.itdWidthCartonIn >= itd.itdHeightCartonIn AND itd.itdHeightCartonIn >= itd.itdDepthCartonIn) OR (itd.itdDepthCartonIn >= itd.itdHeightCartonIn AND itd.itdHeightCartonIn >= itd.itdWidthCartonIn) THEN ROUND(itd.itdHeightCartonIn+2, 0)
		WHEN (itd.itdHeightCartonIn >= itd.itdWidthCartonIn AND itd.itdWidthCartonIn >= itd.itdDepthCartonIn) OR (itd.itdDepthCartonIn >= itd.itdWidthCartonIn AND itd.itdWidthCartonIn >= itd.itdHeightCartonIn) THEN ROUND(itd.itdWidthCartonIn+2, 0)
		WHEN (itd.itdWidthCartonIn >= itd.itdDepthCartonIn AND itd.itdDepthCartonIn >= itd.itdHeightCartonIn) OR (itd.itdHeightCartonIn >= itd.itdDepthCartonIn AND itd.itdDepthCartonIn >= itd.itdWidthCartonIn) THEN ROUND(itd.itdDepthCartonIn+2, 0)
	END AS [Calc_Width_vboard],
	CASE 
		WHEN itd.itdWidthCartonIn <= itd.itdHeightCartonIn AND itd.itdWidthCartonIn <= itd.itdDepthCartonIn THEN ROUND(itd.itdWidthCartonIn+2, 0)
		WHEN itd.itdHeightCartonIn <= itd.itdWidthCartonIn AND itd.itdHeightCartonIn <= itd.itdDepthCartonIn THEN ROUND(itd.itdHeightCartonIn+2, 0)
		WHEN itd.itdDepthCartonIn <= itd.itdWidthCartonIn AND itd.itdDepthCartonIn <= itd.itdHeightCartonIn THEN ROUND(itd.itdDepthCartonIn+2, 0)
	END AS [Calc_Height_vboard],
	CASE 
		WHEN itd.itdWidthCartonIn >= itd.itdHeightCartonIn AND itd.itdWidthCartonIn >= itd.itdDepthCartonIn 
			THEN (2 * (ROUND(itd.itdHeightCartonIn+2, 0)) + 2*(ROUND(itd.itdDepthCartonIn+2, 0)) + ROUND(itd.itdWidthCartonIn+1, 0))
		WHEN itd.itdHeightCartonIn >= itd.itdWidthCartonIn AND itd.itdHeightCartonIn >= itd.itdDepthCartonIn 
			THEN (2 * (ROUND(itd.itdWidthCartonIn+2, 0)) + 2*(ROUND(itd.itdDepthCartonIn+2, 0)) + ROUND(itd.itdHeightCartonIn+1, 0))
		WHEN itd.itdDepthCartonIn >= itd.itdWidthCartonIn AND itd.itdDepthCartonIn >= itd.itdHeightCartonIn 
			THEN (2 * (ROUND(itd.itdHeightCartonIn+2, 0)) + 2*(ROUND(itd.itdWidthCartonIn+2, 0)) + ROUND(itd.itdDepthCartonIn+1, 0))
					END AS [Calc_Girth],
	CASE 
		WHEN itd.itdWidthCartonIn >= itd.itdHeightCartonIn AND itd.itdWidthCartonIn >= itd.itdDepthCartonIn 
			THEN (2 * (ROUND(itd.itdHeightCartonIn+2, 0) + ROUND(itd.itdDepthCartonIn+2, 0)) + ROUND(itd.itdWidthCartonIn+1, 0))
		WHEN itd.itdHeightCartonIn >= itd.itdWidthCartonIn AND itd.itdHeightCartonIn >= itd.itdDepthCartonIn 
			THEN (2 * (ROUND(itd.itdWidthCartonIn+2, 0) + ROUND(itd.itdDepthCartonIn+2, 0)) + ROUND(itd.itdHeightCartonIn+1, 0))
		WHEN itd.itdDepthCartonIn >= itd.itdWidthCartonIn AND itd.itdDepthCartonIn >= itd.itdHeightCartonIn 
			THEN (2 * (ROUND(itd.itdWidthCartonIn+2, 0) + ROUND(itd.itdHeightCartonIn+2, 0)) + ROUND(itd.itdDepthCartonIn+1, 0))
	END AS [Length + Girth_vboard],
    itm.colors AS [Color],
	ser.serExclusiveComment AS [Series Exclusive Comment],
	itm.itmExclusiveComment AS [Item Exclusive Comment],
    itm.itmUPCCode AS [UPC Code],
    itm.itmUPCCheckDigit AS [UPC Check Digit],
	CASE WHEN standalone.ipcId = 'itmStandAlone' THEN 'Yes' ELSE 'No' END AS [Stand Alone Item],
	env.ienExpressShipCode as iteExpressService_ITMUC1A,
		ienVBoard AS [VBoard],
	ienCertifiedPackage AS [Certified Pack],
	grpLookupCode AS [Merchandising Group]
FROM 
    [$(Databricks)].[masterdata_productknowledge].[itemmaster]  AS itm  LEFT JOIN
    [$(Databricks)].[masterdata_productknowledge].[itemdimensions] AS itd ON itm.item_sku = itd.itdItnbr LEFT JOIN 
	[$(Databricks)].[masterdata_productknowledge].[item_env] AS env ON itm.item_sku = env.ienItemNumber AND ienEnvironmentCode = 'AFI' LEFT JOIN 
	[$(Source_Data)].[MasterData_ItemMaster_AFI].[GENDESC]  AS gd ON itm.itmGdescd = gd.GDCODE LEFT JOIN
	[$(Databricks)].[masterdata_productknowledge].[itempublishcodes] ON itm.item_sku = itempublishcodes.ipcItnbr LEFT JOIN
	[$(Databricks)].[masterdata_productknowledge].[itemseries] AS ser ON itm.series_no = ser.series_no LEFT JOIN
	[$(Databricks)].[masterdata_productknowledge].[seriesgroupinglookup] ON ser.[grouping] = seriesgroupinglookup.grpLookupId LEFT JOIN 
	[$(Databricks)].[masterdata_productknowledge].[seriespublishcodes]  ON ser.series_no = seriespublishcodes.spuSeriesNum LEFT JOIN
	[$(Source_Data)].[Wholesale_Marketing].[MarketLookUp] AS ml ON itm.itmMarket = ml.mktId LEFT JOIN 
	[$(Databricks)].[masterdata_productknowledge].[itemclass]  ON env.ienItemClass = itemclass.iclitcls LEFT JOIN
	[$(Source_Data)].[Wholesale_Marketing].[FinancialDivision]  AS fdi ON itemclass.iclFinancial = fdi.Fdifinancialdiv LEFT JOIN
	(
		SELECT DISTINCT 
			[ipcId],
			[ipcItnbr]
		FROM 
			[$(Databricks)].[masterdata_productknowledge].[itempublishcodes] as itempublishcodes
		WHERE 
			ipcId = 'itmStandAlone'
	) AS standalone ON itm.item_sku = standalone.ipcItnbr
WHERE
	(itempublishcodes.ipcId = 'itmCAT' OR spuId = 'serCat')
	AND itm.itmStatus IN ('A', '', 'N')
	AND itm.item_name NOT IN ('Wall Art Display Unit', 'Wall Mount Ashley Eagle', 'Podium (4/CN)', 'P.O.S. Station', 'EVC Case Secure Kit (10/CN)', 'Display Mattress/Box (2RQD)', 'Hook On Display Rails', 'Bolt On Short Display Rails', 'EVC Twin Bed Mattress/Box', 'Plug', 'Package Item Required', 'Package Skus', '4 Piece Wall Unit 1', 'Package Item Sellable')
	AND itm.item_sku NOT IN ('100-62', '5100-40B', '5100-40P', '5100-41B', '5100-41P', '21900PKG', '48300PKG', '49200PKG', '57200PKG', '99900PKG', 'D313PKG', 'D442PKG', 'D442PKG2', 'H371PKG', '45301PKG', '59402PKG', '76802PKG', 'D389PKG')
)


SELECT 
       Distinct p.[Item No.] as '[ItemNo]'
      ,p.[Series No.] as 'SeriesNo'
      ,p.[Merchandising Group] as 'MerchandisingGroup'
      ,p.[AS400 Description] as 'AS400Description'
      ,p.[Description Code] as 'DescriptionCode'
      ,p.[General Description] as 'GeneralDescription'
      ,p.[Introduction Market] as 'IntroductionMarket'
      ,p.[Status]
      ,p.[Financial Division] as 'FinancialDivision'
      ,p.[Import/Domestic] as 'ImportDomestic'
      ,p.[Qty in Box] as 'QtyinBox'
      ,p.[Unit Of Measure] as 'UnitofMeasure'
      ,p.[Color]
      ,p.[Series Exclusive Comment] as 'SeriesExclusiveComment'
      ,p.[Item Exclusive Comment] as 'ItemExclusiveComment'
      ,p.[UPC Code] as 'UPCCode'
      ,p.[UPC Check Digit] as 'UPCCheckDigit'
      ,p.[Stand Alone Item] as 'StandAloneItem'
      ,p.[iteExpressService_ITMUC1A] as 'ExpressFlag'
      ,case when p.[VBoard] = '1' then 'Y' when p.[VBoard] = '0' then 'N' Else cast(p.[VBoard] as char) End as 'VBoardFlag'
 ,(case when exists (select 1
                          from (
						         select ipcItemNumber, ipcId, eldLookupValueDescription ,eldLookupCode
                                 from [$(Databricks)].[masterdata_productknowledge].[itempackagecertification]
                                 left join [$(Databricks)].[masterdata_productknowledge].[engineeringlookupdetail] 
                                 on eldLookupCode = 104 
							   )t2
                          where p.[Item No.]  = t2.ipcItemNumber 
                         )
             then 'Y' else 'N'
        end) as CertifiedPack      ,p.[PK_Product_Width] as 'PKProductWidth'
      ,p.[PK_Product_Depth] as 'PKProductDepth'
      ,p.[PK_Product_Height] as 'PkProductHeight'
      ,p.[PK_Width] as 'PKWidth'
      ,p.[PK_Depth] as 'PKDepth'
      ,p.[PK_Height] as 'PkHeight'
      ,CASE p.[PK Dimensions Confirmed]
       WHEN '0' THEN 'False'
       WHEN '1' THEN 'True' END AS 'PKDimensionsConfirmed'
      ,p.[Weight]
      ,p.[Calc_Length] as 'CalcLength'
      ,p.[Calc_Width] as 'CalcWidth'
      ,p.[Calc_Height] as 'CalcHeight'
	        ,p.[Calc_Girth] as 'CalcGirth'
      ,p.[Length + Girth] as 'LengthGirth'
      ,p.[Calc_Length_vboard] as 'CalcLengthvboard'
      ,p.[Calc_Width_vboard] as 'CalcWidthvboard'
      ,p.[Calc_Height_vboard] as 'CalcHeightvboard'
      ,p.[Length + Girth_vboard] as 'LengthGirthvboard'
      ,w.[WeightinLbs]
      ,w.[Zone2]
      ,w.[Zone3]
      ,w.[Zone4]
      ,w.[Zone5]
      ,w.[Zone6]
      ,w.[Zone7]
      ,w.[Zone8]
      ,v.[Description]
      ,v.[FinanceDivision]
      ,v.[VendorNumber]
      ,v.[VendorName]
      ,v.[VendorOffice]
      ,v.[VendorSplit]
      ,case when d.[iteDeliverInPackage] = '1' then 'Y' when d.[iteDeliverInPackage] = '0' then 'N' 
	  else cast(d.[iteDeliverInPackage] as char) end as 'DelvInPkg'
      ,case when p.[iteExpressService_ITMUC1A] IS NOT Null or p.[iteExpressService_ITMUC1A] = '' THEN p.[iteExpressService_ITMUC1A] End as 'AshleyExpFlag'
         ,d.[iteItemNumber] as 'Express ItemNo'
      ,n.[ReceiptDate]
         ,CASE WHEN t.[sdeItemNumber] IS NULL THEN '' ELSE 'Yes' END as 'UPSShippablePackage'

         ,CASE WHEN  p.[Introduction Market] = 'Supplier Direct Ship' THEN 'Supplier Direct Ship'
     ELSE 'AFI'
END as Sku_Code

      ,CASE WHEN (p.[Calc_Length]*p.[Calc_Width]*p.[Calc_Height]) = 0 THEN 'Dimensions Needed'
     WHEN p.[Weight] > 150 THEN
         CASE WHEN p.[Calc_Length]>108 THEN
             CASE WHEN (p.[Length + Girth]) > 165 THEN 'Weight;Length,Girth'
             ELSE 'Weight,Length' END
         ELSE
             CASE WHEN (p.[Length + Girth]) > 165 THEN 'Weight;Girth'
             ELSE 'Weight' END
         END
     ELSE
         CASE WHEN p.[Calc_Length]>108 THEN
             CASE WHEN (p.[Length + Girth]) > 165 THEN 'Length,Girth'
             ELSE 'Length' END
         ELSE
             CASE WHEN (p.[Length + Girth]) > 165 THEN 'Girth'
             ELSE 'Ship' END
         END
     END AS UPSExpress
  
        ,CASE 
    WHEN (p.[Calc_Length] * p.[Calc_Width] * p.[Calc_Height]) = 0 THEN 'Dimensions Needed'
    WHEN p.[Weight] > 145 THEN
        CASE
            WHEN p.[Calc_Length] > 106 THEN
                CASE
                    WHEN p.[Length + Girth] > 160 THEN 'Weight;Length,Girth'
                    ELSE 'Weight,Length'
                END
            ELSE
                CASE
                    WHEN p.[Length + Girth] > 160 THEN 'Weight;Girth'
                    ELSE 'Weight'
                END
        END
    ELSE
        CASE
            WHEN p.[Calc_Length] > 106 THEN
                CASE
                    WHEN p.[Length + Girth] > 160 THEN 'Length,Girth'
                    ELSE 'Length'
                END
            ELSE
                CASE
                    WHEN p.[Length + Girth] > 160 THEN 'Girth'
                    ELSE 'Ship'
                END
        END
END AS AFI_UPS_Express

       ,CASE 
    WHEN (p.[Calc_Length_vboard] * p.[Calc_Width_vboard] * p.[Calc_Height_vboard]) = 0 THEN 'Dimensions Needed'
    WHEN p.[Weight] > 145 THEN
        CASE
            WHEN p.[Calc_Length_vboard] > 106 THEN
                CASE
                    WHEN p.[Length + Girth_vboard] > 160 THEN 'Weight;Length,Girth'
                    ELSE 'Weight,Length'
                END
            ELSE
                CASE
                    WHEN p.[Length + Girth_vboard] > 160 THEN 'Weight;Girth'
                    ELSE 'Weight'
                END
        END
    ELSE
        CASE
            WHEN p.[Calc_Length_vboard] > 106 THEN
                CASE
                    WHEN p.[Length + Girth_vboard] > 160 THEN 'Length,Girth'
                    ELSE 'Length'
                END
            ELSE
                CASE
                    WHEN p.[Length + Girth_vboard] > 160 THEN 'Girth'
                    ELSE 'Ship'
                END
        END
END as AFI_UPS_Express_W_VBoard

       ,(1.73 + w.[Zone3]) +
    CASE 
        WHEN p.[Calc_Length] > 48 OR p.[Calc_Width] > 30 THEN 5.76 
        ELSE 0 
    END +
    CASE 
        WHEN p.[Weight] > 70 THEN 5.76 
        ELSE 0 
    END +
    CASE 
        WHEN p.[Calc_Length] > 96 OR p.[Length + Girth] >= 130 THEN 45 
        ELSE 0 
    END +
    CASE 
        WHEN p.[Calc_Length] > 108 THEN 425 
        WHEN p.[Length + Girth] > 165 THEN 425 
        WHEN p.[Weight] > 150 THEN 425 
        ELSE 0 
    END as Shipping_Charge
       
       ,CASE 
             WHEN n.[ItemNumber] IS NOT NULL AND p.[Item No.] IS NOT NULL
             THEN 'DNR'
             ELSE NULL
END AS DNR 
       
       ,CASE
        WHEN d.[iteItemNumber] LIKE '100-%' THEN 'Other'
        WHEN d.[iteItemNumber] LIKE 'B%' THEN 'Bedroom'
        WHEN d.[iteItemNumber] LIKE 'D%' THEN 'Dinning'
        WHEN d.[iteItemNumber] LIKE 'R%' THEN 'Rug'
        WHEN d.[iteItemNumber] LIKE 'A%' THEN 'Accessory'
        WHEN d.[iteItemNumber] LIKE 'L%' THEN 'Lamp'
        WHEN d.[iteItemNumber] LIKE 'W%' THEN 'Wall Unit'
        WHEN d.[iteItemNumber] LIKE 'H%' THEN 'Home Office'
        WHEN d.[iteItemNumber] LIKE 'T%' THEN 'Occasional'
        WHEN d.[iteItemNumber] LIKE 'M%' THEN 'Bedding'
        WHEN d.[iteItemNumber] LIKE 'Q%' THEN 'TOB'
        WHEN d.[iteItemNumber] LIKE 'P%' THEN 'Outdoor'
        WHEN d.[iteItemNumber] LIKE 'B100%' THEN 'Store Display'
        WHEN d.[iteItemNumber] LIKE 'M%' THEN 'Bedding'
        ELSE 'UPH'
    END AS 'ProductCategory'
	,u.[USChampion]
   ,CONCAT (s.[First Receipt Date], ' ', s.[Manufacture Date]) as 'Receipt_Manu_Date'

  FROM 
  ItemDescriptions as p
  LEFT JOIN [$(Databricks)].[masterdata_productknowledge].[item] as d ON p.[Item No.] = d.[iteItemNumber]
  LEFT JOIN [Quality_DW].[FactVendorSplit] as v ON p.[Item No.] = v.[ItemNumber]
  LEFT JOIN [Quality_DW].[DimUPSWeightFee] as w ON w.[WeightinLbs] = p.[Weight]
  LEFT JOIN [Quality_DW].[FactNotRecommendedExpress] as n ON n.[ItemNumber] = p.[Item No.]
  LEFT JOIN [$(Databricks)].[masterdata_productknowledge].[setdetail] as t ON p.[Item No.] = t.[sdeItemNumber]
  LEFT JOIN [Quality_DW].[DimUsChampion] as u ON v.[VendorNumber] = u.[vendorNo]
  LEFT JOIN [Quality_DW].[DimSpeedtomarketCQIDetails] as s ON p.[Item No.]  = s.[Item SKU]
  


  
