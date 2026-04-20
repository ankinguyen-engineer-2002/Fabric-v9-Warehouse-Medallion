CREATE TABLE [CostAccounting_DW].[DimCustomerDetails]
(
	[CustomerDetailKey] [int] NOT NULL,
	[Customer Number] [char](8) NULL,
	[Ship To Number] [char](4) NOT NULL,
	[Bill To Status] [char](1) NOT NULL,
	[Ship To Status] [char](1) NOT NULL,
	[Business Type] [varchar](30) NOT NULL,
	[Homestore Flag] [char](1) NOT NULL,
	[Customer Terms Description] [varchar](20) NOT NULL,
	[Bill To Name] [varchar](25) NOT NULL,
	[Bill To Address 1] [varchar](25) NOT NULL,
	[Bill To Address 2] [varchar](50) NOT NULL,
	[Bill To City] [varchar](25) NOT NULL,
	[Bill To State] [char](2) NOT NULL,
	[Bill To Zip Code] [varchar](10) NOT NULL,
	[Bill To Country] [char](3) NOT NULL,
	[Ship To Name] [varchar](25) NOT NULL,
	[Ship To Address 1] [varchar](25) NOT NULL,
	[Ship To Address 2] [varchar](25) NOT NULL,
	[Ship To City] [varchar](25) NOT NULL,
	[Ship To State] [char](2) NOT NULL,
	[Ship To Zip Code] [varchar](10) NOT NULL,
	[Ship To Country] [char](3) NOT NULL,
	[Commission Code] [char](3) NOT NULL,
	[Price Code] [char](6) NOT NULL,
	[Freight Code] [char](3) NOT NULL,
	[Freigth Code Description] [varchar](30) NOT NULL,
	[Item Discount Code] [char](3) NOT NULL,
	[Discount Code Description] [varchar](30) NOT NULL
);


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_Zip_Code]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To Zip Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_Status]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To Status]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_State]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To State]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_Number]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To Number]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_Name]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_Country]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To Country]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_City]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To City]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_Address_2]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To Address 2]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Ship_To_Address_1]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Ship To Address 1]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Price_Code]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Price Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Item_Discount_Code]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Item Discount Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Homestore_Flag]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Homestore Flag]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Freigth_Code_Description]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Freigth Code Description]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Freight_Code]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Freight Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Discount_Code_Description]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Discount Code Description]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Customer_Terms_Description]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Customer Terms Description]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Customer_Number]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Customer Number]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Commission_Code]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Commission Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Business_Type]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Business Type]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_Zip_Code]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To Zip Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_Status]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To Status]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_State]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To State]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_Name]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_Country]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To Country]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_City]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To City]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_Address_2]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To Address 2]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_Bill_To_Address_1]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [Bill To Address 1]
    );


GO
CREATE STATISTICS [Stat_DimCustomerDetails_CustomerDetailKey]
    ON [CostAccounting_DW].[DimCustomerDetails]
    (
        [CustomerDetailKey]
    );

