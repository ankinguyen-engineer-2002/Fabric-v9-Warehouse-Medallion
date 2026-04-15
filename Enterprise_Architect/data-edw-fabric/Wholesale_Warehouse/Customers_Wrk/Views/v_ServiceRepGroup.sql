CREATE VIEW Customers_Wrk.v_ServiceRepGroup
AS
SELECT 
[crgGroupID] AS [GroupID],
[crgUserID] AS [UserID],
[usra] AS [AddedByUser],
CAST([dtea] AS [datetime2](6)) AS [DateAdded],
[usrc] AS [ChangeByUser],
CAST([dtec] AS [datetime2](6)) AS [DateChange],
[crgGroupDescription] AS [GroupDescription]
FROM [$(Source_Data)].[Wholesale_Customers].[ServiceRepGroup]
GO

