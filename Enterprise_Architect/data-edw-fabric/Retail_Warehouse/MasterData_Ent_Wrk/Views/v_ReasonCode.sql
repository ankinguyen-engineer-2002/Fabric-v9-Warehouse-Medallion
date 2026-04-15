-- Auto Generated (Do not modify) D5F81AC2257C4A55A19A7644A58D43BC50AB840E1D8837763D94AC8F2FD9CCF5
CREATE VIEW [MasterData_Ent_Wrk].[v_ReasonCode]
AS
SELECT
	rcdw.ReasonCodeID,
	rcdw.Description AS ReasonCodeName,
	rcdw.ReasonType,
	rc.RSNCAT AS RollUpCode,
	rcdw.DateCreated,
	rcdw.DateChanged
FROM [$(Source_Data)].[Retail_Corporate].[ReasonCode] rcdw
LEFT JOIN [$(Source_Data)].[Retail_External].[ReasonCode] rc
ON rcdw.ReasonCodeID = rc.ID;