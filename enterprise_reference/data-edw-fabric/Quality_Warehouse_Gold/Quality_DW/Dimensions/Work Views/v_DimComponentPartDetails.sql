Create view Quality_DW_Wrk.v_DimComponentPartDetails
AS 
SELECT  [Part SKU] = x.ITNBR
 , [Item Class Code] = TRIM(a.ITCLS)
 , [Responsible Office] = ISNULL(v.VNAMA,'N/A')
 , [Item Class Name] = ISNULL(cls.DESCR,'N/A')
 , [Item Class] = ISNULL(RTRIM(a.ITCLS)+' - '+cls.DESCR,'N/A')
 , [Part Description] = TRIM(a.ITDSC)
 , [AFI Item Status] = TRIM(x.MFPUS)
 , [AFI Item Status Description] = ISNULL(SC.iscDescrip,'N/A') 
 , [Import/Domestic Code] = TRIM(ISNULL(EV.ProductOrigin,'D'))
 , [Country of Origin] = TRIM(ISNULL(ctrDescrip,'N/A'))
 , [Primary Site ID] =TRIM(x.CEX)
 , [Primary Vendor] = TRIM(ISNULL(a.VNDNR,'N/A'))
 ,[Manufacturing Status Change Date] = CASE x.ITSCDT WHEN 0 THEN NULL ELSE CAST(CAST(x.ITSCDT AS VARCHAR) AS DATE) END
 ,[Site ID] = a.STID
FROM [$(Source_Data)].[MasterData_ItemMaster_AFI].[ITMEXT] x 
JOIN [$(Source_Data)].[MasterData_ItemMaster_AFI].[ITMRVA] a  ON x.ITNBR = a.ITNBR AND a.UUCA = '1'
JOIN [$(Source_Data)].[MasterData_ItemMaster_AFI].[ITMRVB] b  ON a.STID = b.STID AND x.ITNBR = b.ITNBR AND a.ITRV = b.ITRV
JOIN [$(Source_Data)].[MasterData_ItemMaster_AFI].[ITMRVC] c  ON a.STID = c.STID AND x.ITNBR = c.ITNBR AND a.ITRV = c.ITRV
LEFT JOIN [$(Databricks)].[masterdata_itemMaster_afi].[aitmcls] cls  ON a.ITCLS = cls.ITMCL
LEFT JOIN [$(Source_Data)].[wholesale_pricing_afi].[SalesClass] sls  ON x.ISCLS = sls.sclSlscls
LEFT JOIN [$(Source_Data)].[Wholesale_Purchasing_AFI].[VENNAM]  v  ON a.VNDNR = v.VNDNR
LEFT JOIN [$(Databricks)].[wholesale_purchasing_afi].[frghtf] f  ON v.FOBCD = f.FOBCD
LEFT JOIN [$(Source_Data)].[MasterData_GeographicData].[CountryMaster]  ON f.UUCABE = ctrCountry
LEFT JOIN [$(Databricks)].[masterdata_productknowledge].[itemstatuscode] SC  ON SC.iscCode = x.MFPUS
LEFT JOIN [$(Source_Data)].[Wholesale_Purchasing_AFI].[EXTVNDR] EV  ON a.VNDNR = EV.VEND_NUM
