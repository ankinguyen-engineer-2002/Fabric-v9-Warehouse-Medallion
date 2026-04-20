CREATE VIEW [PowerBI_Retail_Wrk].[v_CoSales_VIPCustCommLogMasterData]
AS
SELECT  [Operation],
			[MasterDataID],
			[Type],
			[Value],
			[Order],
			[ActiveStatus]
            from [$(Source_data)].[Retail_Miniapps].[VIPCustCommLog_MasterData]
GO

