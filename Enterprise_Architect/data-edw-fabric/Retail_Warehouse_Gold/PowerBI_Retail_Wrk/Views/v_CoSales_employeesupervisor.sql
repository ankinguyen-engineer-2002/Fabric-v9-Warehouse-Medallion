CREATE VIEW [PowerBI_Retail_Wrk].[v_CoSales_employeesupervisor]
AS
SELECT      [EmployeeNumber],
			[SupervisorEmployeeNumber],
			[SupervisorFullName]
 from [$(Retail_Warehouse)].[MasterData_HR_UKG_Enh].[EmployeeSupervisor]
GO