-- Auto Generated (Do not modify) D92B6390A4C89B7A3C7C93D2347D7BF5AC5CDCCA3A96379E230DC816364686E5
CREATE   VIEW [MasterData_Retail_Ent_Wrk].[v_SalesPerson]
AS
WITH CTE_SalesPerson AS
(
	SELECT
		sptdg.ID AS SalesPersonID
		, sptdg.NAME AS SalesPersonName
		, sptdg.SMTYP AS SalesPersonTypeID
		, sptdg.active_status AS ActiveStatus
		, sptdg.MGRID AS ManagerID
		, sptdg.ADDR_1 AS Address1
		, sptdg.ADDR_2 AS Address2
		, sptdg.CITY AS City
		, sptdg.ST AS State
		, sptdg.ZIP AS PostalCode
		, sptdg.PHONE_NO AS PhoneNumber
		, sptdg.HSTORE AS HomeStore
		, sptdg.CSTORE AS CommissionStore
		, ISNULL(sps.CommissionRate, CAST(0.00 AS DEC(19,4))) AS CommissionRate
		, sptdg.people_id AS PeopleID
		, sptdg.PrimaryID
		, sptdg.InitialPrimaryID
		, sps.DateCreated
		, sps.DateChanged
	FROM [$(Source_Data)].[Retail_Miniapps].[Salesman] sptdg
	LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Salesperson] sps
	ON sps.SalespersonID = sptdg.ID

	UNION ALL

	SELECT
        spst.SalespersonID AS SalesPersonID
        , spst.Name AS SalesPersonName
        , NULL AS SalesPersonTypeID
        , NULL AS ActiveStatus
        , NULL AS ManagerID
        , spst.Address1
        , spst.Address2
        , spst.City
        , spst.State
        , spst.PostalCodeID AS PostalCode
        , spst.Phone AS PhoneNumber
        , spst.SellingStoreID AS HomeStore
        , spst.SellingStoreID AS CommissionStore
        , ISNULL(spst.CommissionRate, CAST(0.00 AS DEC(19,4))) AS CommissionRate
        , NULL AS PeopleID
        , spst.SalespersonID AS PrimaryID
        , NULL AS InitialPrimaryID
        , spst.DateCreated
        , spst.DateChanged
    FROM [$(Source_Data)].[Retail_Corporate].[Salesperson] spst
    WHERE NOT EXISTS 
    (
        SELECT 1
        FROM [$(Source_Data)].[Retail_Miniapps].[Salesman] sptdg
        WHERE sptdg.ID = spst.SalespersonID
    )
)
, CTE_PeopleRecords AS
(
    SELECT 
        PeopleID ,
        HireDate,
        ROW_NUMBER() OVER(PARTITION BY PeopleID ORDER BY HireDate DESC) AS RN1
    FROM [$(Source_Data)].[Retail_Miniapps].[PeopleRecords]
)
, CTE_Combined AS
(
	SELECT
		sp.SalesPersonID
		, st.StaffID
		, LTRIM(st.EmployeeNbr, '0') AS EmployeeNumber
		, st.StaffTypeID
		, sp.SalesPersonName
		, sp.SalesPersonTypeID
		, sp.ActiveStatus
		, sp.ManagerID
		, sp.Address1
		, sp.Address2
		, sp.City
		, sp.State
		, sp.PostalCode
		, sp.PhoneNumber
		, sp.HomeStore
		, sp.CommissionStore
		, sp.CommissionRate
		, sp.PeopleID
		, sp.PrimaryID
		, sp.InitialPrimaryID
		, sp.DateCreated
		, sp.DateChanged
		, p.HireDate
		, ROW_NUMBER() OVER(PARTITION BY sp.SalesPersonID ORDER BY sp.SalesPersonID) RN
	FROM CTE_SalesPerson sp
	LEFT JOIN [$(Source_Data)].[Retail_Corporate].[Staff] st
	ON sp.SalesPersonID = st.SalespersonID
	LEFT JOIN CTE_PeopleRecords p
    ON sp.PeopleID = p.PeopleID AND p.RN1 = 1 
)

SELECT 
	SalesPersonID
	, StaffID
	, EmployeeNumber
	, StaffTypeID
	, SalesPersonName
	, SalesPersonTypeID
	, ActiveStatus
	, ManagerID
	, Address1
	, Address2
	, City
	, State
	, PostalCode
	, PhoneNumber
	, HomeStore
	, CommissionStore
	, CommissionRate
	, PeopleID
	, PrimaryID
	, InitialPrimaryID
	, DateCreated
	, DateChanged
	, HireDate
FROM CTE_Combined
WHERE RN = 1 
;