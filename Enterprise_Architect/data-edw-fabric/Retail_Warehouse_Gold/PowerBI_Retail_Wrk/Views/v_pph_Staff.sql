-- Auto Generated (Do not modify) E2EB27994619A6F036B7D2738F8B704D9AF0C8C5D3F3965F4B055F7D7D4CE786
CREATE view PowerBI_Retail_Wrk.v_PPH_Staff 
AS select 
RecStatus,
SourceID,
StaffID,
PeopleID,
StaffName, 
CompanyID,
EmployeeNumber,
ServiceLocationID, 
StaffTypeID,
LanguageCode,
DateCreated,
DateChanged
from 
[$(Retail_Warehouse)].[MasterData_Retail_Ent].[Staff]