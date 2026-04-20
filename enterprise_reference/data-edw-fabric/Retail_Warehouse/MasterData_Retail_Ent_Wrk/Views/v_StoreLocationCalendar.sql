-- Auto Generated (Do not modify) 04C7ADBBC7BD3B098C8B3ACED5AC15219A01FFADC87D4BC4E848A20B868BC186
CREATE VIEW [MasterData_Retail_Ent_Wrk].[v_StoreLocationCalendar]
AS
SELECT 
	CAST(LocationID AS INT) StoreID
    , TransDateKey
    , OpenTime
    , CloseTime
    , IsOpen
    , IsDelivery
    , DateChanged
    , ChangedBy
    , YearMonthKey
    , YearKey
FROM [$(Source_Data)].[Retail_External].[LocationCalendar];