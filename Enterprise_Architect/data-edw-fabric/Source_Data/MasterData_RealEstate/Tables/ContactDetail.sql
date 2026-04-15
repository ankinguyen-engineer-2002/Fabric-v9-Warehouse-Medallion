CREATE TABLE [MasterData_RealEstate].[ContactDetail] (

	[Unit_Number] varchar(50) NULL, 
	[File_ID] varchar(128) NULL, 
	[Site_ID] varchar(128) NOT NULL, 
	[Total_SQFT] decimal(10,2) NULL, 
	[Showroom_SQFT] decimal(10,2) NULL, 
	[Soft_open_date] date NULL, 
	[Store_type] varchar(128) NULL, 
	[City] varchar(50) NULL, 
	[Zipcode] varchar(50) NULL, 
	[Property_Type] varchar(128) NULL, 
	[Commencement_Date] date NULL, 
	[Expiration_Date] date NULL
);