CREATE   VIEW [Retail_DW_Core_Wrk].[v_LEAS_DimAcimaStaffedStores]
AS SELECT 
    Store, 
    [ACIMAStaffLocationStatus]
FROM [$(Source_Data)].[Retail_ExternalFiles].[AcimaStaffedLocations]
WHERE Store <> 'Total'
GO

