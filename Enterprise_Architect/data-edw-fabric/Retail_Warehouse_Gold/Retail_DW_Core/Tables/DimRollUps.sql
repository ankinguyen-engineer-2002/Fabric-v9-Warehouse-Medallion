CREATE TABLE [Retail_DW_Core].[DimRollUps] (
    [StoreID]      INT           NULL,
    [RollUp]       VARCHAR (50)  NULL,
    [RollUpFilter] VARCHAR (50)  NULL,
    [StoreType]    VARCHAR (20)  NULL,
    [StoreNameID]  VARCHAR (100) NULL
);