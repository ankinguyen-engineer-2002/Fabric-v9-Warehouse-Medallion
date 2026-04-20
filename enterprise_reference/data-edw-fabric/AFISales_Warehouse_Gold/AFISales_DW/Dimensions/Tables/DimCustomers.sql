CREATE TABLE [AFISales_DW].[DimCustomers]
    (
        [Account And Shipto Number]     [CHAR](13)       NULL,
        [Customer Name]                 [VARCHAR](25)    NULL,
        [Customer Account Number]       [CHAR](8)        NULL,
        [Customer Shipto Number]        [CHAR](4)        NULL,
        [Account Exception Flag]        [INT]            NULL,
        [Discount Code]                 [CHAR](3)        NULL,
        [Discount Code Description]     [VARCHAR](30)    NULL,
        [AFI Discount Description]      [VARCHAR](35)    NULL,
        [Price Code]                    [CHAR](6)        NULL,
        [Price Code Description]        [VARCHAR](30)    NULL,
        [AFI Price Description]         [VARCHAR](38)    NULL,
        [Freight Code]                  [CHAR](3)        NULL,
        [Freight Code Description]      [VARCHAR](30)    NULL,
        [AFI Freight Description]       [VARCHAR](35)    NULL,
        [Commission Code]               [CHAR](3)        NULL,
        [Commission Code Description]   [VARCHAR](30)    NULL,
        [AFI Commission Code]           [VARCHAR](35)    NULL,
        [Customer Shipto Name]          [VARCHAR](35)    NULL,
        [Customer Segment]              [INT]        NULL,
        [Business Type Code]            [CHAR](2)        NULL,
        [Business Type]                 [VARCHAR](30)    NOT NULL,
        [Reporting Business Type]       [VARCHAR](50)    NULL,
        [Customer Service RepID]        [CHAR](5)        NOT NULL,
        [Customer Service Agent Name]   [VARCHAR](50)    NOT NULL,
        [Customer Service Group ID]     [CHAR](2)        NOT NULL,
        [Customer Service Group Leader] [VARCHAR](10)    NOT NULL,
        [Store Address ID]              [INT]            NULL,
        [Shipto AddressID]              [INT]            NULL,
        [Primary Sales Territory]       [CHAR](5)        NULL,
        [Shipto Sales Territory]        [CHAR](5)        NULL,
        [Customer Account Status]       [CHAR](1)        NULL,
        [DFI Account Flag]              [CHAR](1)        NOT NULL,
        [AFI Credit Terms]              [VARCHAR](30)    NULL,
        [Terms Code]                    [CHAR](3)        NULL,
        [Credit Territory Code]         [INT]        NULL,
        [Default Warehouse]             [CHAR](3)        NULL,
        [Terms Description]             [VARCHAR](25)    NULL,
        [Route Zone]                    [CHAR](3)        NOT NULL,
        [Route Region]                  [CHAR](3)        NOT NULL,
        [Bill To Address 1]             [VARCHAR](35)    NULL,
        [Bill To Address 2]             [VARCHAR](35)    NULL,
        [Bill To Address 3]             [VARCHAR](35)    NULL,
        [Bill To Address 4]             [VARCHAR](35)    NULL,
        [Bill To Address 5]             [VARCHAR](35)    NULL,
        [Bill To City]                  [VARCHAR](35)    NULL,
        [Bill To State]                 [CHAR](2)        NULL,
        [Bill To Zip Code]              [VARCHAR](10)    NULL,
        [Bill To Country]               [CHAR](3)        NULL,
        [Bill To-Buyer Name]            [VARCHAR](50)    NULL,
        [Bill To-Buyer Phone]           [VARCHAR](50)    NULL,
        [Bill To-Buyer Fax]             [VARCHAR](50)    NULL,
        [Bill To-Buyer Email]           [VARCHAR](50)    NULL,
        [Bill To-Receiving Name]        [VARCHAR](50)    NULL,
        [Bill To-Receiving Phone]       [VARCHAR](50)    NULL,
        [Bill To-Receiving Fax]         [VARCHAR](50)    NULL,
        [Bill To-Receiving Email]       [VARCHAR](50)    NULL,
        [Ship To-Buyer Name]            [VARCHAR](50)    NULL,
        [Ship To-Buyer Phone]           [VARCHAR](50)    NULL,
        [Ship To-Buyer Fax]             [VARCHAR](50)    NULL,
        [Ship To-Buyer Email]           [VARCHAR](50)    NULL,
        [Ship To-Receiving Name]        [VARCHAR](50)    NULL,
        [Ship To-Receiving Phone]       [VARCHAR](50)    NULL,
        [Ship To-Receiving Fax]         [VARCHAR](50)    NULL,
        [Ship To-Receiving Email]       [VARCHAR](50)    NULL,
        [Shipto Details]                [VARCHAR](80)    NULL,
        [ACI Amount]                    [DECIMAL](15, 2) NULL,
        [Outstanding Balance]           [DECIMAL](14, 2) NOT NULL,
        [Days Beyond Terms - 90]        [DECIMAL](14, 0) NOT NULL,
        [Days Beyond Terms - 365]       [DECIMAL](14, 0) NOT NULL,
        [Credit Limit]                  [DECIMAL](14, 0) NOT NULL,
        [Invoice Type]                  [CHAR](1)        NULL,
        [EPay Flag]                     [CHAR](1)        NULL,
        [Currency Type]                 [CHAR](3)        NULL,
        [Highest Credit]                [DECIMAL](28, 2) NOT NULL,
        [ABC Account-Current Year]      [CHAR](1)        NOT NULL,
        [ABC Account-Previous Year]     [CHAR](1)        NOT NULL,
        [ABC Account-2 Years Ago]       [CHAR](1)        NOT NULL,
        [HS Owner]                      [VARCHAR](50)    NULL,
        [District Manager]              [VARCHAR](50)    NULL,
        [CustomerandAccountNumber]      [VARCHAR](50)    NULL
    );



GO
CREATE STATISTICS [Stat_DimCustomers_Shipto_Number]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Shipto Number]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Account_Number]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Account Number]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Account_And_Shipto_Number]
    ON [AFISales_DW].[DimCustomers]
    (
        [Account And Shipto Number]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Store_Address_ID]
    ON [AFISales_DW].[DimCustomers]
    (
        [Store Address ID]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Shipto_Sales_Territory]
    ON [AFISales_DW].[DimCustomers]
    (
        [Shipto Sales Territory]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Shipto_Details]
    ON [AFISales_DW].[DimCustomers]
    (
        [Shipto Details]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Shipto_AddressID]
    ON [AFISales_DW].[DimCustomers]
    (
        [Shipto AddressID]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Receiving_Phone]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Receiving Phone]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Receiving_Name]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Receiving Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Receiving_Fax]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Receiving Fax]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Receiving_Email]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Receiving Email]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Buyer_Phone]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Buyer Phone]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Buyer_Name]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Buyer Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Buyer_Fax]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Buyer Fax]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Ship_To_Buyer_Email]
    ON [AFISales_DW].[DimCustomers]
    (
        [Ship To-Buyer Email]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Route_Zone]
    ON [AFISales_DW].[DimCustomers]
    (
        [Route Zone]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Reporting_Business_Type]
    ON [AFISales_DW].[DimCustomers]
    (
        [Reporting Business Type]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Primary_Sales_Territory]
    ON [AFISales_DW].[DimCustomers]
    (
        [Primary Sales Territory]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Price_Code]
    ON [AFISales_DW].[DimCustomers]
    (
        [Price Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Outstanding_Balance]
    ON [AFISales_DW].[DimCustomers]
    (
        [Outstanding Balance]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Invoice_Type]
    ON [AFISales_DW].[DimCustomers]
    (
        [Invoice Type]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_HS_Owner]
    ON [AFISales_DW].[DimCustomers]
    (
        [HS Owner]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Highest_Credit]
    ON [AFISales_DW].[DimCustomers]
    (
        [Highest Credit]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_EPay_Flag]
    ON [AFISales_DW].[DimCustomers]
    (
        [EPay Flag]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Discount_Code]
    ON [AFISales_DW].[DimCustomers]
    (
        [Discount Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_DFI_Account_Flag]
    ON [AFISales_DW].[DimCustomers]
    (
        [DFI Account Flag]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Default_Warehouse]
    ON [AFISales_DW].[DimCustomers]
    (
        [Default Warehouse]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Days_Beyond_Terms___90]
    ON [AFISales_DW].[DimCustomers]
    (
        [Days Beyond Terms - 90]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Days_Beyond_Terms___365]
    ON [AFISales_DW].[DimCustomers]
    (
        [Days Beyond Terms - 365]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Shipto_Name]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Shipto Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Service_RepID]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Service RepID]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Service_Group_Leader]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Service Group Leader]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Service_Group_ID]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Service Group ID]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Service_Agent_Name]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Service Agent Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Segment]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Segment]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Name]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Account_Status]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Account Status]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Customer_Account_Number]
    ON [AFISales_DW].[DimCustomers]
    (
        [Customer Account Number]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Currency_Type]
    ON [AFISales_DW].[DimCustomers]
    (
        [Currency Type]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Credit_Territory_Code]
    ON [AFISales_DW].[DimCustomers]
    (
        [Credit Territory Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Credit_Limit]
    ON [AFISales_DW].[DimCustomers]
    (
        [Credit Limit]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Commission_Code]
    ON [AFISales_DW].[DimCustomers]
    (
        [Commission Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Business_Type_Code]
    ON [AFISales_DW].[DimCustomers]
    (
        [Business Type Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Business_Type]
    ON [AFISales_DW].[DimCustomers]
    (
        [Business Type]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Zip_Code]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To Zip Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_State]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To State]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Receiving_Phone]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Receiving Phone]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Receiving_Name]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Receiving Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Receiving_Fax]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Receiving Fax]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Receiving_Email]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Receiving Email]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Country]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To Country]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_City]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To City]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Buyer_Phone]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Buyer Phone]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Buyer_Name]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Buyer Name]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Buyer_Fax]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Buyer Fax]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Buyer_Email]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To-Buyer Email]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Address_5]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To Address 5]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Address_4]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To Address 4]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Address_3]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To Address 3]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Address_2]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To Address 2]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Bill_To_Address_1]
    ON [AFISales_DW].[DimCustomers]
    (
        [Bill To Address 1]
    );



GO
CREATE STATISTICS [Stat_DimCustomers_AFI_Credit_Terms]
    ON [AFISales_DW].[DimCustomers]
    (
        [AFI Credit Terms]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_AFI_Commission_Code]
    ON [AFISales_DW].[DimCustomers]
    (
        [AFI Commission Code]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_ACI_Amount]
    ON [AFISales_DW].[DimCustomers]
    (
        [ACI Amount]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_Account_Exception_Flag]
    ON [AFISales_DW].[DimCustomers]
    (
        [Account Exception Flag]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_ABC_Account_Previous_Year]
    ON [AFISales_DW].[DimCustomers]
    (
        [ABC Account-Previous Year]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_ABC_Account_Current_Year]
    ON [AFISales_DW].[DimCustomers]
    (
        [ABC Account-Current Year]
    );


GO
CREATE STATISTICS [Stat_DimCustomers_ABC_Account_2_Years_Ago]
    ON [AFISales_DW].[DimCustomers]
    (
        [ABC Account-2 Years Ago]
    );

