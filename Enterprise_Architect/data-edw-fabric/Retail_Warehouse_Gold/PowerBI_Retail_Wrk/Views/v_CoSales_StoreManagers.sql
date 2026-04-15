CREATE VIEW [PowerBI_Retail_Wrk].[v_CoSales_StoreManagers]
AS
SELECT      [Operation],
			[Store],
			[DistrictManager],
			[DirectorManager]
            from [$(Source_data)].[Retail_Miniapps].[StoreManagers]
GO

