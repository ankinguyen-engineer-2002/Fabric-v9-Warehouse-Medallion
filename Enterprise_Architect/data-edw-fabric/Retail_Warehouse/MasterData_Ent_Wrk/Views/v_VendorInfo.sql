-- Auto Generated (Do not modify) 97469FD48D9E7B471872AAE488BAF8D7021EBF13BE2A1F30C29B78D11C2DBE44
CREATE VIEW [MasterData_Ent_Wrk].[v_VendorInfo]
AS
SELECT 
	VendorID
	, Name AS VendorName
	, Class AS VendorClass
	, Address1
	, Address2
	, City
	, State
	, PostalCodeID AS PostalCode
	, CountryID
FROM [$(Source_Data)].[Retail_Corporate].[Vendor];