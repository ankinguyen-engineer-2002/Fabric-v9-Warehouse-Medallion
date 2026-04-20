CREATE TABLE [Wholesale_Marketing].[Goals] (

	[Goagoalid] int NULL, 
	[Goagoalname] varchar(102) NULL, 
	[Goagoaldate] datetime2(6) NULL, 
	[Goagoalsetter] varchar(102) NULL, 
	[Goaproductdescription] varchar(17) NULL, 
	[Goatopaccountstatus] bit NULL, 
	[Goagoalyear] int NULL, 
	[Goagoalmonth] int NULL, 
	[Goadivision] char(1) NULL, 
	[Goaproductline] char(1) NULL, 
	[Goacustomernumber] char(8) NULL, 
	[Goashiptonumber] char(4) NULL, 
	[Goanetwrittengoal] float NULL, 
	[Goaplacementgoal] float NULL, 
	[Goavelocitygoal] float NULL, 
	[Goastoreaddressid] int NULL, 
	[Goashiptoaddressid] int NULL
);