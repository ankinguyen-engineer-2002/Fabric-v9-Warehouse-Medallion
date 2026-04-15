CREATE TABLE [Retail_DW_Core].[APPS_FactOrders] (

	[OrderID] varchar(800) NULL, 
	[TransDate] datetime2(6) NULL, 
	[CustomerID] varchar(800) NULL, 
	[StoreID] varchar(800) NULL, 
	[AttributedWrittenSales] decimal(18,4) NULL, 
	[Email] varchar(800) NULL, 
	[HomePhone] varchar(1016) NULL, 
	[WorkPhone] varchar(800) NULL, 
	[CellPhone] varchar(800) NULL, 
	[AppointmentID] int NULL, 
	[AppointmentDateTime] datetime2(6) NULL, 
	[AppointmentDateCreated] datetime2(6) NULL, 
	[MinutesDifferenceAppointmentCreate] int NULL, 
	[SalespersonID] varchar(800) NULL, 
	[Conv Type] varchar(800) NULL, 
	[Same Day] decimal(18,4) NULL
);