-- Auto Generated (Do not modify) F4389F036D217C9A13835A9D26F2BABC0FF9FF63B9211F3E0B17A35FAE06DF21
CREATE VIEW [Retail_DW_Core_Wrk].[v_DimTransCodeMap]
AS
SELECT
	TransCodeID
	, TransCodeGroup
	, OutputValue AS Description
	, TransCodeMultiplier
	, InResult
	, InSelect
FROM [$(Source_Data)].[Retail_External].[TransCodeMap];