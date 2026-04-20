-- Auto Generated (Do not modify) 0123152699A39AC532F4587B28C022B2D93ED9CF320DF2A245E0CE1F251EDA45
CREATE VIEW [MasterData_Retail_Ent_Wrk].[v_StoreLocation]
AS
WITH CTE_Store AS
(
SELECT 
	LTRIM(s.StoreID, '0') StoreID
	, s.LocnType AS LocationType
	, s.Phone
	, s.ReceiveFriday
	, s.ReceiveMonday
	, s.ReceiveSaturday
	, s.ReceiveSunday
	, s.ReceiveThursday
	, s.ReceiveTuesday
	, s.ReceiveWednesday
FROM [$(Source_Data)].[Retail_Corporate].[Store] s
WHERE s.LocnType IN ('ST', 'WH')
)

, CTE_SiteMaster AS
(
SELECT
	sm.RetailSystemNumber AS StoreID
	, sm.OperationID
	, sm.OperationIDStoris
	, sm.ErpDatabaseName AS Operation
	, sm.ProfitCenter
	, ext.LocationIDDislay AS LocationIDDisplay
	, st.LocationType
	, ext.ServiceLocationID
	, ext.ShipLocationID
	, ext.StockLocationID
	, ext.SCMLocationID
	, CASE WHEN sm.RetailSystemNumber IN ('88','751', '752', '753', '754') THEN 'AFHS' ELSE ext.StoreBrandID END AS StoreBrandID
	, sm.SourceId AS SourceID
	, sm.EnterpriseLocation
	, sm.EnterpriseStore
	, sm.SiteName AS LocationName
	, sm.Complocation AS CompLocation
	, sm.StoreAddress AS Address1
	, sm.Address2
	, sm.City
	, sm.DistrictID
	, ext.DistrictName
	, sm.State
	, sm.DistrictRegionID AS RegionID
	, ext.RegionName
	, sm.SiteCountryCode AS CountryCode
	, sm.Code AS Country
	, sm.Zip AS PostalCodeID
	, st.Phone
	, sm.LicContact AS LicenseeContact
	, sm.LegalEntityId AS LegalEntityID
	, sm.Latitude
	, sm.Longitude
	, sm.OperationalStatus
	, sm.TimeZone
	, sm.AccountNumber
	, sm.Name AS AccountName
	, sm.ShipToNum AS ShipToNumber
	, sm.AFIShipToName
	, sm.AcctShipTo AS AccountShipTo
	, sm.CompanyCode
	, sm.CorporateFinanceGrouping
	, sm.financialUnitNumber AS FinancialUnitNumber
	, sm.SVP_name AS SVPName
	, sm.VpName AS VPName
	, sm.SrRDName
	, sm.RegionalDirector
	, sm.TerritoryManager
	, sm.StoreManager
	, sm.HomestoreOwner
	, ext.OwnerNumber AS HomestoreOwnerNumber
	, ext.OwnerGroup AS HomestoreOwnerGroup
	, sm.CorporateMarket
	, sm.CorporateRegion
	, sm.SubCorporateRegion
	, sm.SquareFootage AS SquareFeet
	, ext.TotalSquareFeet
	, ext.ProductiveSquareFeet
	, sm.HomestoreType
	, sm.InternationalStore
	, sm.SoftOpenDate
	, sm.GrandOpenDate
	, sm.CloseDate
	, CAST(sm.SameStoreDate AS DATE) AS SameStoreDate
	, CAST(sm.SameStoreDateClosed AS DATE) AS SameStoreDateClosed
	, sm.DATE AS MigrationDate
	, sm.MigratedtoStoris
	, sm.ShopperTrakLocID
	, sm.ScoreboardStoreID
	, CAST(NULLIF(sm.TaxRate, '') AS DECIMAL(19,4)) TaxRate
	, sm.ConvertCogs
	, sm.CurrencyType
	, ext.HasTrafficCounter
	, st.ReceiveFriday
	, st.ReceiveMonday
	, st.ReceiveSaturday
	, st.ReceiveSunday
	, st.ReceiveThursday
	, st.ReceiveTuesday
	, st.ReceiveWednesday
	, ext.IsVirtual
	, ROW_NUMBER() OVER(PARTITION BY sm.RetailSystemNumber ORDER BY sm.RetailSystemNumber) AS RN
FROM [$(Source_Data)].[MasterData_Retail].[SiteMasterLocations] sm
LEFT JOIN CTE_Store st
ON sm.RetailSystemNumber = st.StoreID
LEFT JOIN [$(Source_Data)].[Retail_External].[store] ext
ON LTRIM(ext.LocationID, '0') = st.StoreID
WHERE sm.CompanyCode IN ('AGR','DSG')
AND sm.RetailSystemNumber IS NOT NULL
)

SELECT
	StoreID
	, OperationID
	, OperationIDStoris
	, Operation
	, ProfitCenter
	, LocationIDDisplay
	, LocationType
	, ServiceLocationID
	, ShipLocationID
	, StockLocationID
	, SCMLocationID
	, StoreBrandID
	, SourceID
	, EnterpriseLocation
	, EnterpriseStore
	, LocationName
	, CompLocation
	, Address1
	, Address2
	, City
	, DistrictID
	, DistrictName
	, State
	, RegionID
	, RegionName
	, CountryCode
	, Country
	, PostalCodeID
	, Phone
	, LicenseeContact
	, LegalEntityID
	, Latitude
	, Longitude
	, OperationalStatus
	, TimeZone
	, AccountNumber
	, AccountName
	, ShipToNumber
	, AFIShipToName
	, AccountShipTo
	, CompanyCode
	, CorporateFinanceGrouping
	, FinancialUnitNumber
	, SVPName
	, VPName
	, SrRDName
	, RegionalDirector
	, TerritoryManager
	, StoreManager
	, HomestoreOwner
	, HomestoreOwnerNumber
	, HomestoreOwnerGroup
	, CorporateMarket
	, CorporateRegion
	, SubCorporateRegion
	, SquareFeet
	, TotalSquareFeet
	, ProductiveSquareFeet
	, HomestoreType
	, InternationalStore
	, SoftOpenDate
	, GrandOpenDate
	, CloseDate
	, SameStoreDate
	, SameStoreDateClosed
	, MigrationDate
	, MigratedtoStoris
	, ShopperTrakLocID
	, ScoreboardStoreID
	, TaxRate
	, ConvertCogs
	, CurrencyType
	, HasTrafficCounter
	, ReceiveFriday
	, ReceiveMonday
	, ReceiveSaturday
	, ReceiveSunday
	, ReceiveThursday
	, ReceiveTuesday
	, ReceiveWednesday
	, IsVirtual
FROM CTE_SiteMaster
WHERE RN = 1;