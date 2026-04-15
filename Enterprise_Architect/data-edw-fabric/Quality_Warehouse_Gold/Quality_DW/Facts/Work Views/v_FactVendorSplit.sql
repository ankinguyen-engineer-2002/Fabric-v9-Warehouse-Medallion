




Create view [Quality_DW_Wrk].[v_FactVendorSplit] 
as
SELECT DISTINCT
	LTRIM(RTRIM(vendorSplit.vdpitemnum)) AS ItemNumber,
	itment.ITDSC AS [Description],
	itmext.MFPUS AS [Status],
	CASE itmext.UUCCIM
		WHEN 'BED' THEN 'BEDDING'
		WHEN 'IUC' THEN 'IMPORT UPHOLSTERY'
		WHEN 'IMP' THEN 'IMPORT CASEGOODS'
		WHEN 'UPH' THEN 'UPHOLSTERY'
		WHEN 'DOM' THEN 'CASEGOODS'
		ELSE itmext.UUCCIM
	END AS [Finance Division],
	vendorSplit.vdpvendornum AS [Vendor Number],
	vennam.VNAME AS [VendorName],
	vennam.VNAMA AS [VendorOffice],
	vendorSplit.vdpsplit AS [Vendor Split]
FROM 
	[$(Databricks)].[wholesale_vendors_afi].[vendorpricing] AS vendorSplit INNER JOIN 
	[$(Source_Data)].[Wholesale_Purchasing_AFI].[VENNAM] as vennam ON vendorSplit.vdpvendornum =vennam.VNDNR LEFT JOIN
	[$(Source_Data)].[MasterData_ItemMaster_AFI].[ITMEXT] AS itmext  ON vendorSplit.vdpitemnum = itmext.ITNBR LEFT JOIN
	[$(Databricks)].[masterdata_itemmaster_afi].[itment] AS itment  ON vendorSplit.vdpitemnum = itment.ITNBR
WHERE 
	vdpsplit <> 0
