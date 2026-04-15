CREATE PROC [Quality_DW].[usp_Refresh_FactProductList] AS

/* Change Control -----------------------------------------------------------------------------------------------------------
* Procedure: [Quality_DW].[usp_Refresh_FactProductList]
* Description: 

---------------------------------------------------------------------------------------------------------------------------*/

BEGIN

  DECLARE
            @String    VARCHAR(5000),
            @DateValue DATETIME,
            @User      VARCHAR(500);
SET @DateValue =  GETDATE()
SET @String = 'Quality_DW.usp_Refresh_FactProductList'
SET @User = SYSTEM_USER

 INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
        VALUES
            (
                @String, @DateValue, @User, 'Process Start'
            )


BEGIN TRY

DECLARE
	@UPS_Exp_Weight				decimal,
	@UPS_Exp_Length				decimal,
	@UPS_Exp_LenPlusGirth		decimal;

SET @UPS_Exp_Weight				= 145;
SET @UPS_Exp_Length				= 106;
SET @UPS_Exp_LenPlusGirth		= 160;

  /**************************/
 /**  Create work tables  **/
/**************************/

-- If work table already exists then truncate it else create it.
IF OBJECT_ID('#tblSLdat','U') IS NOT NULL
   TRUNCATE TABLE #tblSLdat
ELSE
	BEGIN
		CREATE TABLE #tblSLdat (
			SL_ItemNo			varchar (15)	NOT NULL,
			SL_SeriesNo			varchar (16)	NOT NULL,
			SL_MerchGroup       varchar (35)    NULL,
			SL_AS400Desc		varchar (100)	NULL,
			SL_DescCode			decimal (4)		NULL,
			SL_GENDESC			varchar (40)	NULL,
			SL_IntroMkt			varchar (30)	NULL,
			SL_IStatus			varchar (1)		NULL,
			SL_FinDiv			varchar (30)	NULL,
			SL_ImpDom			varchar (1)		NULL,
			SL_QIB				decimal (4)		NULL,
			SL_UOM				varchar (2)		NULL,
			SL_PKProdWidth		decimal (7,2)	NULL,
			SL_PKProdDepth		decimal (7,2)	NULL,
			SL_PKProdHeight		decimal (7,2)	NULL,
			SL_PKWidth			decimal (7,2)	NULL,
			SL_PKDepth			decimal (7,2)	NULL,
			SL_PKHeight			decimal (7,2)	NULL,
			SL_DimConfirm		bit				NOT NULL,
			SL_Weight			decimal			NULL,
			SL_CalcLength		decimal			NULL,
			SL_CalcWidth		decimal			NULL,
			SL_CalcHeight		decimal			NULL,
			SL_LenPlusGirth		decimal			NULL,
			SL_CalcLengthVB		decimal			NULL,
			SL_CalcWidthVB		decimal			NULL,
			SL_CalcHeightVB		decimal			NULL,
			SL_LenPlusGirthVB	decimal			NULL,
			SL_Colors			varchar (25)	NULL,
			SL_SeriesExclComm	varchar (60)	NULL,
			SL_ItemExclComm		varchar (60)	NULL,
			SL_UPCcode			decimal (10)	NULL,
			SL_UPCchkDigit		decimal (1)		NULL,
			SL_StandAlone		varchar (3)		NOT NULL,
			SL_ExpressFlag		varchar (1)		NULL,
			SL_VBoardFlag       bit             NULL)
			

	END;

-- If work table already exists then truncate it else create it.
IF OBJECT_ID('#tblITMlist','U') IS NOT NULL
	TRUNCATE TABLE #tblITMlist
ELSE
	BEGIN
		CREATE TABLE #tblITMlist (ITM_LIST	varchar	(15) NOT NULL) 

	END;

IF OBJECT_ID('#tblPKGlist','U') IS NOT NULL
	TRUNCATE TABLE #tblPKGlist 
ELSE
	BEGIN
		CREATE TABLE #tblPKGlist  (
			PKG_ItemNo			varchar (15)	NOT NULL,
			PKG_Yes				varchar (3)		NULL) 

	END;

  /************************/
 /**  Load work tables  **/
/************************/

INSERT INTO #tblSLdat (
	SL_ItemNo,
	SL_SeriesNo,
	SL_MerchGroup,
	SL_AS400Desc,
	SL_DescCode,
	SL_GENDESC,
	SL_IntroMkt,
	SL_IStatus,
	SL_FinDiv,
	SL_ImpDom,
	SL_QIB,
	SL_UOM,
	SL_PKProdWidth,
	SL_PKProdDepth,
	SL_PKProdHeight,
	SL_PKWidth,
	SL_PKDepth,
	SL_PKHeight,
	SL_DimConfirm,
	SL_Weight,
	SL_CalcLength,
	SL_CalcWidth,
	SL_CalcHeight,
	SL_LenPlusGirth,
	SL_CalcLengthVB,
	SL_CalcWidthVB,
	SL_CalcHeightVB,
	SL_LenPlusGirthVB,
	SL_Colors,
	SL_SeriesExclComm,
	SL_ItemExclComm,
	SL_UPCcode,
	SL_UPCchkDigit,
	SL_StandAlone,
	SL_ExpressFlag,
	SL_VBoardFlag
	)
SELECT
    a.[Item No],
    a.[Series No],
	a.[Merchandising Group],
    a.[AS400 Description],
	a.[Description Code],
	a.[General Description],
	a.[Introduction Market],
    a.[Status],
	a.[Financial Division],
	a.[Import/Domestic],
    a.[Qty in Box],
	a.[Unit Of Measure],
	a.[PK_Product_Width],
	a.[PK_Product_Depth],
	a.[PK_Product_Height],
	a.[PK_Width],
	a.[PK_Depth],
	a.[PK_Height],
	COALESCE(a.[PK Dimensions Confirmed], 0),
	a.[Weight],
	a.[Calc_Length],
	a.[Calc_Width],
	a.[Calc_Height],
	a.[Length + Girth],
	a.[Calc_Length_vboard],
	a.[Calc_Width_vboard],
	a.[Calc_Height_vboard],
	a.[Length + Girth_vboard],
    a.[Color],
	a.[Series Exclusive Comment],
	a.[Item Exclusive Comment],
    a.[UPC Code],
    a.[UPC Check Digit],
	a.[Stand Alone Item],
	a.iteExpressService_ITMUC1A,
	a.[VBoard]
FROM  (
SELECT DISTINCT 
    RTRIM(LTRIM(itm.item_sku)) AS [Item No],
    itm.series_no AS [Series No],
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
	CASE WHEN standalone.Id = 'itmStandAlone' THEN 'Yes' ELSE 'No' END AS [Stand Alone Item],
	Item.iteExpressService_ITMUC1A,
	ienVBoard AS [VBoard],
	grpLookupCode AS [Merchandising Group]
FROM 
    [$(Databricks)].[masterdata_productknowledge].[itemmaster] AS itm  LEFT JOIN
    [$(Databricks)].[masterdata_productknowledge].[itemdimensions] AS itd ON itm.item_sku = itd.itdItnbr LEFT JOIN 
	[$(Databricks)].[masterdata_productknowledge].[item_env] AS env ON itm.item_sku = env.ienItemNumber AND ienEnvironmentCode = 'AFI' LEFT JOIN 
	[$(Source_Data)].[MasterData_ItemMaster_AFI].[GENDESC]  AS gd ON itm.itmGdescd = gd.GDCODE LEFT JOIN
	[$(Databricks)].[masterdata_productknowledge].[itempublishcodes] AS ItemPublishCodes ON itm.item_sku = ItemPublishCodes.[ipcItnbr] LEFT JOIN
	[$(Databricks)].[masterdata_productknowledge].[itemseries] AS ser ON itm.series_no = ser.series_no LEFT JOIN
	[$(Databricks)].[masterdata_productknowledge].[seriesgroupinglookup] AS SeriesGroupingLookup ON ser.[grouping] = SeriesGroupingLookup.grpLookupId LEFT JOIN 
	[$(Databricks)].[masterdata_productknowledge].[seriespublishcodes] AS SeriesPublishCodes ON ser.series_no = SeriesPublishCodes.spuSeriesNum LEFT JOIN
	[$(Source_Data)].[Wholesale_Marketing].[MarketLookUp] AS ml ON itm.itmMarket = ml.mktId LEFT JOIN 
	[$(Databricks)].[masterdata_productknowledge].[item] AS Item ON itm.item_sku = Item.iteItemNumber LEFT JOIN
	[$(Databricks)].[masterdata_productknowledge].[itemclass] AS ItemClass ON Item.iteClass = ItemClass.iclitcls LEFT JOIN
	[$(Source_Data)].[Wholesale_Marketing].[FinancialDivision]  AS fdi ON ItemClass.iclFinancial = fdi.Fdifinancialdiv LEFT JOIN 
	(
		SELECT DISTINCT 
			ItemPublishCodes.[ipcId] as Id,
			ItemPublishCodes.[ipcItnbr] as ipcItnbr
		FROM 
			[$(Databricks)].[masterdata_productknowledge].[itempublishcodes] As ItemPublishCodes
		WHERE 
			ItemPublishCodes.ipcId = 'itmStandAlone'
	) AS standalone ON itm.item_sku = standalone.ipcItnbr
WHERE 
	(ItemPublishCodes.ipcId = 'itmCAT' OR spuId = 'serCat')
	AND itm.itmStatus IN ('A', '', 'N')
	AND itm.item_name NOT IN ('Wall Art Display Unit', 'Wall Mount Ashley Eagle', 'Podium (4/CN)', 'P.O.S. Station', 'EVC Case Secure Kit (10/CN)', 'Display Mattress/Box (2RQD)', 'Hook On Display Rails', 'Bolt On Short Display Rails', 'EVC Twin Bed Mattress/Box', 'Plug', 'Package Item Required', 'Package Skus', '4 Piece Wall Unit 1', 'Package Item Sellable')
	AND itm.item_sku NOT IN ('100-62', '5100-40B', '5100-40P', '5100-41B', '5100-41P', '21900PKG', '48300PKG', '49200PKG', '57200PKG', '99900PKG', 'D313PKG', 'D442PKG', 'D442PKG2', 'H371PKG', '45301PKG', '59402PKG', '76802PKG', 'D389PKG')

) a
  /*******************************************************/
 /**  Load list of items for use in the package query  **/
/*******************************************************/

INSERT INTO #tblITMlist (ITM_LIST)
SELECT
	SL_ItemNo
FROM
	#tblSLdat
WHERE
	(SL_CalcLength * SL_CalcWidth * SL_CalcHeight <> 0) AND
	(SL_Weight <= @UPS_Exp_Weight AND
	 SL_CalcLength <= @UPS_Exp_Length AND 
	 SL_LenPlusGirth <= @UPS_Exp_LenPlusGirth) AND
	 SL_ExpressFlag <> 'N';

  /***************************************************************************/
 /**  Load list of package items that can express ship - item number only  **/
/***************************************************************************/

INSERT INTO #tblPKGlist (
	PKG_ItemNo,
	PKG_Yes
	)
SELECT 
	sdeItemNumber as 'Pkg Item Number',
	'Yes' as 'UPS Shippable Package'
FROM  [$(Databricks)].[masterdata_productknowledge].[setdetail] SetDetail

WHERE
	SetDetail.sdeSetNumber NOT IN ( 'B102B11', 'B102B12', 'B102B13', 'B102B6', 'B102TN-BKBD', 'B102TN-PNL-A', 'B103B11', 'B103B12', 'B103B13', 'B103B6', 'B103TN-BKBD', 'B103TN-PNL-A', 'B140B11', 'B140B4', 'B140B8', 'B182B11', 'B182FL-UPHL', 'B182TN-UPHL', 'B228B10', 'B228B11', 'B228B17', 'B228B18', 'B228B19', 'B228B20', 'B228B21', 'B228B22', 'B228B23', 'B228B3', 'B228B7', 'B233B45', 'B239B33', 'B248QN-PSTR', 'B256B1', 'B264QN-PSTR', 'B298B11', 'B298B8', 'B298B9', 'B299B2', 'B362FL-PNL', 'B362FL-STRGA', 'B362FL-STRGB', 'B362TN-PNL', 'B362TN-STRGA', 'B362TN-STRGB', 'B376CL/KG-PNL', 'B376FL-SLGH', 'B376KG-PNL', 'B376QN-PNL', 'B376TN-SLGH', 'B397FL-PNL', 'B397FL-STRG', 'B397TN-PNL', 'B397TN-STRG', 'B402QN-UPHL', 'B429 KG-PSTRB', 'B429 QN-PSTRB', 'B429CL/KG PSTRB', 'B447B2', 'B447FL-SLGHB', 'B447FL-STRG', 'B447TN-SLGHB', 'B447TN-STRG', 'B455B22', 'B455CL/KG-PNL', 'B455CL/KG-UPHL', 'B455FL-BKBD', 'B455FL-PNL', 'B455KG-PNL', 'B455KG-UPHL', 'B455QN-PNL', 'B455QN-UPHL', 'B455TN-BKBD', 'B455TN-PNL', 'B465B3', 'B473FL-PNL', 'B473FL-STRG', 'B473QN-PNL', 'B473TN-PNL', 'B473TN-STRG', 'B473YB9', 'B494QN-PNL', 'B502B4', 'B502B5', 'B502D/M', 'B502FL-PNL', 'B502TN-PNL', 'B505B10', 'B505B7', 'B505B8', 'B505D/M', 'B505FL-PNL', 'B505TN/FL-BKBD', 'B505TN-BKBD', 'B506KG-STRG', 'B506QN-PSTR', 'B506QN-STRG', 'B526QN-PNL', 'B531QN-PNL', 'B551QN-CNPY', 'B551QN-PSTR', 'B565QN-PNL', 'B565QN-STRG', 'B571QN-PNL', 'B580FL-STRG', 'B580QN-PNL', 'B580TN-STRG', 'B581QN-PSTR', 'B586CL/KG-STRG', 'B586KG-STRG', 'B586QN-STRG', 'B619QN-PSTR', 'B631QN-PSTR', 'B656QN-PNL', 'B664B7', 'B664QN-STRG-A', 'B676QN-PNL', 'B695QN-PSTR', 'B695QN-SLGH', 'B696B5', 'B696KG-PNL', 'B696QN-PNL', 'D100D1', 'D199D16', 'D313T/B', 'D314T/B', 'D314T/B-A', 'D328D2', 'D328D5', 'D328D8', 'D367D2', 'D391D1', 'D436D4', 'D468D1', 'D550D6', 'D580D7', 'D580T/B', 'D583T/B', 'T399T/B', 'D540SDCA', 'D540SDCB', 'D540SDCC', 'D644SDC') AND 
	SetDetail.sdeSetNumber NOT IN (
		SELECT 
			distinct tblSetDetail.sdeSetNumber 
		FROM
			[$(Databricks)].[masterdata_productknowledge].[setdetail] AS tblSetDetail 
		WHERE
			tblSetDetail.sdeItemNumber NOT IN (select ITM_LIST FROM #tblITMlist)
	)
GROUP BY
	SetDetail.sdeItemNumber;

  /**************************/
 /**  Build final report  **/
/**************************/
EXEC  [$(ETL_Framework)].DW_Developer.usp_DropWorkTable 'Quality_DW.FactProductList_Load'



CREATE TABLE [Quality_DW].[FactProductList_Load]
(
	[ItemNo] [varchar](15) NOT NULL,
	[SeriesNo] [varchar](16) NOT NULL,
	[QtyinBox] [decimal](4, 0) NULL,
	[PKProductWidth] [decimal](7, 2) NULL,
	[PKProductDepth] [decimal](7, 2) NULL,
	[PkProductHeight] [decimal](7, 2) NULL,
	[PKWidth] [decimal](7, 2) NULL,
	[PKDepth] [decimal](7, 2) NULL,
	[PkHeight] [decimal](7, 2) NULL,
	[PKDimensionsConfirmed] [bit] NOT NULL,
	[Weight] [decimal](18, 0) NULL,
	[CalcLength] [decimal](18, 0) NULL,
	[CalcWidth] [decimal](18, 0) NULL,
	[CalcHeight] [decimal](18, 0) NULL,
	[LengthGirth] [decimal](18, 0) NULL,
	[CalcLengthvboard] [decimal](18, 0) NULL,
	[CalcWidthvboard] [decimal](18, 0) NULL,
	[CalcHeightvboard] [decimal](18, 0) NULL,
	[LengthGirthvboard] [decimal](18, 0) NULL,
	[ItemExclusiveComment] [varchar](60) NULL,
	[UPCCode] [decimal](10, 0) NULL,
	[UPCCheckDigit] [decimal](1, 0) NULL,
	[StandAloneItem] [char](3) NOT NULL,
	[ExpressFlag] [char](1) NULL,
	[VBoardFlag] char(7) NULL,
	[UPSShippablePackage] [char](3) NOT NULL,
	[IntroductionMarket] varchar(50) null
)



Insert into [Quality_DW].[FactProductList_Load](
 [ItemNo]
      ,[SeriesNo]
      ,[QtyinBox]
      ,[PKProductWidth]
      ,[PKProductDepth]
      ,[PkProductHeight]
      ,[PKWidth]
      ,[PKDepth]
      ,[PkHeight]
      ,[PKDimensionsConfirmed]
      ,[Weight]
      ,[CalcLength]
      ,[CalcWidth]
      ,[CalcHeight]
      ,[LengthGirth]
      ,[CalcLengthvboard]
      ,[CalcWidthvboard]
      ,[CalcHeightvboard]
      ,[LengthGirthvboard]
	    ,[ItemExclusiveComment]
      ,[UPCCode]
      ,[UPCCheckDigit]
      ,[StandAloneItem]
      ,[ExpressFlag]
      ,[VBoardFlag]
      ,[UPSShippablePackage]
	  ,[IntroductionMarket]
	  )


SELECT
	SL_ItemNo AS 'ItemNo',
	SL_SeriesNo AS 'SeriesNo',
	SL_QIB AS 'Qty in Box',
	SL_PKProdWidth AS 'PK_Product_Width',
	SL_PKProdDepth AS 'PK_Product_Depth',
	SL_PKProdHeight AS 'Pk_Product_Height',
	SL_PKWidth AS 'PK_Width',
	SL_PKDepth AS 'PK_Depth',
	SL_PKHeight AS 'Pk_Height',
	SL_DimConfirm AS 'PK Dimensions Confirmed',
	SL_Weight AS 'Weight',
	SL_CalcLength AS 'CalcLength',
	SL_CalcWidth AS 'CalcWidth',
	SL_CalcHeight AS 'CalcHeight',
	SL_LenPlusGirth AS 'Length + Girth',
	SL_CalcLengthVB AS 'Calc_Length_vboard',
	SL_CalcWidthVB AS 'Calc_Width_vboard',
	SL_CalcHeightVB AS 'Calc_Height_vboard',
	SL_LenPlusGirthVB AS 'Length + Girth_vboard',
	SL_ItemExclComm AS 'Item Exclusive Comment',
	SL_UPCcode AS 'UPC Code',
	SL_UPCchkDigit AS 'UPC Check Digit',
	SL_StandAlone AS 'Stand Alone Item',
	SL_ExpressFlag AS 'Express Flag',
	case when SL_VBoardFlag=1 then 'True' 
	 when SL_VBoardFlag=0 then 'False' end  AS 'VBoard Flag',
	ISNULL(PKG_Yes,'') AS 'UPS Shippable Package',
	SL_IntroMkt as IntroductionMarket
FROM
	#tblSLdat LEFT JOIN
	#tblPKGlist ON #tblSLdat.SL_ItemNo  = #tblPKGlist.PKG_ItemNo



CREATE STATISTICS [Stat_FactProductList_ItemNo]
    ON [Quality_DW].[FactProductList_Load]([ItemNo])


CREATE STATISTICS [Stat_FactProductList_SeriesNo]
    ON [Quality_DW].[FactProductList_Load]([SeriesNo])


CREATE STATISTICS [Stat_FactProductList_QtyinBox]
    ON [Quality_DW].[FactProductList_Load]([QtyinBox])



 EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable '#tblSLdat'



 EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable '#tblITMlist'


 EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable '#tblPKGlist'




 EXEC [$(ETL_Framework)].DW_Developer.usp_DropWorkTable
                        'Quality_DW.FactProductList';

   
                    EXECUTE sp_rename 'Quality_DW.FactProductList_LOAD','FactProductList'


--- Update last modified in Table Dictionary 

   INSERT INTO [$(ETL_Framework)].DW_Developer.TableDictionary_UpdateLog
        VALUES
            (
                'Quality_Warehouse', 'Quality_DW', 'FactProductList', @DateValue
            );

END TRY
     BEGIN CATCH
DECLARE
                @ErrorMessage  VARCHAR(4000),
                @ErrorSeverity INT,
                @ErrorState    INT;
            SET @ErrorMessage = ERROR_MESSAGE();
            SET @ErrorSeverity = ISNULL(ERROR_SEVERITY(), 16);
            SET @ErrorState = ISNULL(ERROR_STATE(), 0);

            SET @DateValue = GETDATE();
            SELECT
                @DateValue = CSTDateValue
            FROM
                [$(ETL_Framework)].DW_Developer.fn_GetDate(@DateValue);
	
 INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog
            VALUES
                (
                    @String, @DateValue, @User, @ErrorMessage
                );

            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

END CATCH


INSERT INTO [$(ETL_Framework)].DW_Developer.AuditLog 
	VALUES 
	(
		@String, @DateValue, @User, 'Process Complete'
	);

END

GO


