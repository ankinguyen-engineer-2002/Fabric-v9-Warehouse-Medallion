-- Auto Generated (Do not modify) 135EF6D6F4154B1258B05F41D04AD7DB9F7571538F198B692CF97A02A236790C
CREATE VIEW [Retail_DW_Core_Wrk].[v_FactOrderHeader]
AS
SELECT
	oh.SourceSystem
	, oh.OrderKey
	, oh.SourceOrderID
	, oh.BaseOrderID
	, oh.LastUpdatedUTC
	, oh.BillToZipOrPostalCode
	, oh.StoreShipTo
	, oh.OrderDate
	, oh.MarketingCodeID
	, oh.TransCodeID
	, oh.CreditHoldCodeID
	, oh.RequestedDate
	, oh.TransactionSaveTime
	, oh.TransactionStartTime
	, oh.PriceExceptionComment
	, oh.IsFinanced
	, oh.OriginalTransDate
	, oh.SuperOrderID
	, oh.LastActivityDate
	, DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) AS REACAge
	, CASE WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) IS NULL THEN NULL
		 WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 1	 THEN '00 - 01 Days'
		 WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 7	 THEN '02 - 07 Days'
		 WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 30 THEN '08 - 30 Days'
		 WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 60 THEN '31 - 60 Days'
		 WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 90 THEN '61 - 90 Days'
		 WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) > 90	 THEN '90+ Days'
		 ELSE 'Unknown'
	END AS AgedDays
	, CASE WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) IS NULL THEN ''
    WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) >= 0 AND DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 1 THEN 'Bad Business'
    WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 30 THEN 'Controllable'
    WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) <= 60 THEN 'Guest Pref'
    WHEN DATEDIFF(DAY, oh.OrderDate, oh.LastActivityDate) > 60 THEN 'Supply Chain'
    ELSE '' END AS REACAgeCategory
FROM [Retail_DW_Core].[FactSalesOrderHeader] oh;