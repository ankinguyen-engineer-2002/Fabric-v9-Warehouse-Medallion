CREATE     PROCEDURE [Retail_DW_Core].[usp_Refresh_DimStoreLocation]
AS

BEGIN

	DECLARE
			@String VARCHAR(5000),
			@DateValue DATETIME,
			@User VARCHAR(500),
			@DestinationDatabase VARCHAR(150),
			@DestinationSchema VARCHAR(150),
			@DestinationTable VARCHAR(150);
			      
	SET @String = 'Retail_DW_Core.usp_Refresh_DimStoreLocation';
	SET @User = SYSTEM_USER;
	SET @DateValue = GETDATE();
	SET @DestinationDatabase = 'Retail_Warehouse';
	SET @DestinationSchema = 'Retail_DW_Core';
	SET @DestinationTable = 'DimStoreLocation';

	SELECT
		@DateValue = CSTDateValue
	FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

	INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
	VALUES
	(
		@String, @DateValue, @User, 'Process Start'
	);

	BEGIN TRY

		DECLARE @MaxID BIGINT = (SELECT ISNULL(MAX(LocationKey),0) FROM [Retail_DW_Core].[DimStoreLocation]);

		UPDATE dst
		SET dst.Operation = src.Operation
			, dst.OperationID = src.OperationID
			, dst.OperationIDStoris = src.OperationIDStoris
			, dst.LocationType = src.LocationType
			, dst.ServiceLocationID = src.ServiceLocationID
			, dst.StockLocationID = src.StockLocationID
			, dst.ShipLocationID = src.ShipLocationID
			, dst.StoreBrandID = src.StoreBrandID
			, dst.LocationName = src.LocationName
			, dst.Address1 = src.Address1
			, dst.Address2 = src.Address2
			, dst.City = src.City
			, dst.PostalCodeID = src.PostalCodeID
			, dst.Phone = src.Phone
			, dst.RegionID = src.RegionID
			, dst.RegionName = src.RegionName
			, dst.DistrictID = src.DistrictID
			, dst.DistrictName = src.DistrictName
			, dst.HasTrafficCounter = src.HasTrafficCounter
			, dst.SoftOpenDate = src.SoftOpenDate
			, dst.GrandOpenDate = src.GrandOpenDate
			, dst.HomestoreOwner = src.HomestoreOwner
			, dst.HomestoreOwnerGroup = src.HomestoreOwnerGroup
			, dst.HomestoreOwnerNumber = src.HomestoreOwnerNumber
			, dst.State = src.State
			, dst.TotalSquareFeet = src.TotalSquareFeet
			, dst.ProductiveSquareFeet = src.ProductiveSquareFeet
			, dst.SCMLocationID = src.SCMLocationID
			, dst.LocationIDDisplay = src.LocationIDDisplay
			, dst.ReceiveMonday = src.ReceiveMonday
			, dst.ReceiveTuesday = src.ReceiveTuesday
			, dst.ReceiveWednesday = src.ReceiveWednesday
			, dst.ReceiveThursday = src.ReceiveThursday
			, dst.ReceiveFriday = src.ReceiveFriday
			, dst.ReceiveSaturday = src.ReceiveSaturday
			, dst.ReceiveSunday = src.ReceiveSunday
			, dst.IsVirtual = src.IsVirtual
			, dst.CompLocation = src.CompLocation
		FROM [Retail_DW_Core].[DimStoreLocation] dst
		INNER JOIN [$(Retail_Warehouse)].[MasterData_Retail_Ent].[StoreLocation] src 
		ON src.StoreID = dst.StoreID;
		
		INSERT INTO [Retail_DW_Core].[DimStoreLocation]
		(
			LocationKey
			, StoreID
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
		)

		SELECT	
			@MaxID + CAST(ROW_NUMBER() OVER (ORDER BY src.StoreID) AS BIGINT) AS LocationKey
			, src.StoreID
			, src.OperationID
			, src.OperationIDStoris
			, src.Operation
			, src.ProfitCenter
			, src.LocationIDDisplay
			, src.LocationType
			, src.ServiceLocationID
			, src.ShipLocationID
			, src.StockLocationID
			, src.SCMLocationID
			, src.StoreBrandID
			, src.SourceID
			, src.EnterpriseLocation
			, src.EnterpriseStore
			, src.LocationName
			, src.CompLocation
			, src.Address1
			, src.Address2
			, src.City
			, src.DistrictID
			, src.DistrictName
			, src.State
			, src.RegionID
			, src.RegionName
			, src.CountryCode
			, src.Country
			, src.PostalCodeID
			, src.Phone
			, src.LicenseeContact
			, src.LegalEntityID
			, src.Latitude
			, src.Longitude
			, src.OperationalStatus
			, src.TimeZone
			, src.AccountNumber
			, src.AccountName
			, src.ShipToNumber
			, src.AFIShipToName
			, src.AccountShipTo
			, src.CompanyCode
			, src.CorporateFinanceGrouping
			, src.FinancialUnitNumber
			, src.SVPName
			, src.VPName
			, src.SrRDName
			, src.RegionalDirector
			, src.TerritoryManager
			, src.StoreManager
			, src.HomestoreOwner
			, src.HomestoreOwnerNumber
			, src.HomestoreOwnerGroup
			, src.CorporateMarket
			, src.CorporateRegion
			, src.SubCorporateRegion
			, src.SquareFeet
			, src.TotalSquareFeet
			, src.ProductiveSquareFeet
			, src.HomestoreType
			, src.InternationalStore
			, src.SoftOpenDate
			, src.GrandOpenDate
			, src.CloseDate
			, src.MigrationDate
			, src.MigratedtoStoris
			, src.ShopperTrakLocID
			, src.ScoreboardStoreID
			, src.TaxRate
			, src.ConvertCogs
			, src.CurrencyType
			, src.HasTrafficCounter
			, src.ReceiveFriday
			, src.ReceiveMonday
			, src.ReceiveSaturday
			, src.ReceiveSunday
			, src.ReceiveThursday
			, src.ReceiveTuesday
			, src.ReceiveWednesday
			, src.IsVirtual
		FROM [$(Retail_Warehouse)].[MasterData_Retail_Ent].[StoreLocation] src
		LEFT OUTER JOIN [Retail_DW_Core].[DimStoreLocation] dst
		ON dst.StoreID = src.StoreID
		WHERE dst.StoreID IS NULL;

		UPDATE [Retail_DW_Core].[DimStoreLocation] SET LocationType = 'ST' WHERE Storeid = 88;

		SET @DateValue = GETDATE();

		SELECT
			@DateValue = CSTDateValue
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, 'Process Complete'
		);

		--- Update last modified in Table Dictionary 
		EXEC [$(ETL_Framework)].[DW_Developer].[usp_UpdateTableDictionary_ModifiedDate] @DestinationDatabase, @DestinationSchema, @DestinationTable
	
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
		FROM [$(ETL_Framework)].[DW_Developer].fn_GetDate(@DateValue);

		INSERT INTO [$(ETL_Framework)].[DW_Developer].[AuditLog]
		VALUES
		(
			@String, @DateValue, @User, @ErrorMessage
		);

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

	END CATCH

END