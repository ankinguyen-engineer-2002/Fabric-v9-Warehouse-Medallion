CREATE VIEW Customers_Wrk.v_ServiceRepID
AS
SELECT 
[csiCssrep] AS [ServiceRepID],
[csiGroupID] AS [GroupID],
CAST([csiContactID] AS [int]) AS [ContactID],
[csiDepartment] AS [Department],
[csiContactType] AS [ContactType],
[usra] AS [AddedByUser],
CAST([dtea] AS [datetime2](6)) AS [DateAdded],
[usrc] AS [ChangeByUser],
CAST([dtec] AS [datetime2](6)) AS [DateChange],
[acrec] AS [ActiveRecord]
FROM [$(Source_Data)].[Wholesale_Customers].[ServiceRepID]
GO

