-- Auto Generated (Do not modify) DF35D24E1D36AEA8607CB5617D725C5D66353177B339EF5CA4E95AF995BF2E35
CREATE VIEW [Retail_Sales_Wrk].[v_SalesOrderFulfillment] 
AS
SELECT
	Address1
	, Address2
	, CellPhone
	, City
	, CODAmt AS CODAmount
	, ContactName
	, CountryID
	, DateChanged
	, DateCreated
	, DeliverToID
	, DeliveryContactDate
	, DeliveryContactStatusID
	, DeliveryInstr AS DeliveryInstruction
	, DesiredDate
	, DispatchTrackDateTime
	, DlvyChrg AS DeliveryCharge
	, DlvyChrgCalculated AS DeliveryChargeCalculated
	, DlvyChrgOverride AS DeliveryChargeOverride
	, DlvyChrgOverrideReasonCodeID AS DeliveryChargeOverrideReasonCodeID
	, EmailAddress
	, FreightCompanyID
	, FulfillmentDate
	, FulfillmentMethod
	, FulfillmentStatus
	, FulfillmentStoreID
	, HandlingMethodCode
	, HandlingMethodOverride
	, HomePhone
	, InstallationChrg AS InstallationCharge
	, InstallationChrgOverride AS InstallationChargeOverride
	, IsInvoiced
	, ManifestNbr AS ManifestNumber
	, ManifestStoreID
	, MerchSubTot AS MerchSubTotal
	, Name
	, NbrOfPostponements AS NumberOfPostponements
	, OrderFulfillmentID
	, OrderID AS SourceOrderID
	, PostalCodeID
	, RecStatus
	, RouteCodeID
	, RoutingNbr AS RoutingNumber
	, SalesTaxExmpNbr AS SalesTaxExemptNumber
	, StaffID
	, State
	, StopTime
	, StorisCreateDateTime
	, TruckNbr AS TruckNumber
	, WmsShipped
	, WmsTransmitted
	, WorkPhone
	, WorkPhoneExt
FROM [$(Source_Data)].[Retail_Corporate].[OrderFulfillment]
WHERE COALESCE(CAST(DateChanged AS DATE), CAST(DateCreated AS DATE)) BETWEEN CAST(GETDATE()-3 AS DATE) AND CAST(GETDATE() AS DATE);