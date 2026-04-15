CREATE TABLE [MasterData_Retail_Ent].[GuestTrafficBudget] (

	[BudgetDate] datetime2(3) NOT NULL, 
	[StoreID] int NOT NULL, 
	[TrafficBudget] decimal(18,10) NULL, 
	[RUBudget] decimal(18,10) NULL, 
	[CloseRateBudget] decimal(18,10) NULL, 
	[FinanceFeeBudget] decimal(18,10) NULL
);