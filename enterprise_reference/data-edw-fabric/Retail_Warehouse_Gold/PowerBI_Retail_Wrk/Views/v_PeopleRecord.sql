-- Auto Generated (Do not modify) 5B61B42C59411BADE5879434C77F8CD65BCD8FC1D47FE6B26FDD5103129AF853
CREATE   VIEW [PowerBI_Retail_Wrk].[v_PeopleRecord]
AS
SELECT [Operation],
			[PeopleID],
			[EmployeeNumber],
			[Email],
			[HireDate],
			[JobID],
			[PeopleType_ID],
			[ActiveStatus],
			[CreatedDate],
			[SupID],
			[FirstName],
			[LastName],
			[EmpStatus],
			[EmpFTPT],
			[LocationID],
			[DivisionID],
			[DepartmentID],
			[RegionID],
			[EmployeeTypeID],
			[SepDate]
FROM [$(Source_Data)].[Retail_Miniapps].[PeopleRecords]