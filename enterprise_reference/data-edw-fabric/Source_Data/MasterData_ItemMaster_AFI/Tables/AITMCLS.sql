CREATE TABLE [MasterData_ItemMaster_AFI].[AITMCLS] (

	[RCDCD] char(2) NOT NULL, 
	[ACTIV] char(1) NOT NULL, 
	[ITMCL] char(4) NOT NULL, 
	[DESCR] varchar(25) NOT NULL, 
	[COUNT] decimal(6,0) NOT NULL, 
	[MOVPRC] decimal(4,1) NOT NULL
);