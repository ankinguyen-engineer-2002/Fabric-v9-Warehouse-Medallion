-- Auto Generated (Do not modify) 25E47671572C0959E2CC6AF0198B2E5546AE26F276941A72C1496D6BCE65BE83
CREATE VIEW [MasterData_Ent_Wrk].[v_CustomerInfo]
AS
SELECT
	CustomerID
	, FirstName
	, LastName
	, FullName
	, HomePhone
	, CellPhone
	, WorkPhone
	, WorkPhoneExt
	, Address1
	, Address2
	, City
	, State
	, PostalCodeID AS PostalCode
	, EmailAddress
	, Class AS CustomerClass
	, StoreID
	, OpenDt AS OpenDate
	, MembershipActive
	, MembershipCancellationDate
	, MembershipCard
	, MembershipFee
	, MembershipLinkedCustomerID
	, MembershipPaymentTypeID
	, MembershipProductID
	, MembershipRenewal
	, MembershipRenewDate
	, MembershipReviewDate
	, MembershipStartDate
	, MembershipStoreID
	, MembershipTerms
	, CASE WHEN Class LIKE 'COM%' OR Class IN ('NOR') THEN 0 ELSE NULL END AS IsRetail
	, NULL AS IsActive
	, DateCreated
	, DateChanged
FROM [$(Source_Data)].[Retail_Corporate].[Customer];