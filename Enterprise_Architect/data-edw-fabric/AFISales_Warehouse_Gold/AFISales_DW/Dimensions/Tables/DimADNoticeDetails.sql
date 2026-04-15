CREATE TABLE [AFISales_DW].[DimAdNoticeDetails] (
    [Key]                            INT           NOT NULL,
    [Customer Account Number]        CHAR (8)      NULL,
    [Ship Number]                    CHAR (4)      NULL,
    [Item Number]                    VARCHAR (15)  NOT NULL,
    [MS Name]                        VARCHAR (35)  NULL,
    [Delivery Date for AD]           DATE          NULL,
    [Start Date for AD]              DATE          NULL,
    [End Date for AD]                DATE          NULL,
    [AD Description]                 VARCHAR (100) NULL,
    [Warehouse]                      CHAR (3)      NOT NULL,
    [AD Comments]                    VARCHAR (500) NULL,
    [AD Date Entered]                DATETIME2 (6) NULL,   --DATETIME
    [Special Discount Name and Code] VARCHAR (25)  NULL
)



GO
CREATE STATISTICS [Stat_DimAdNoticeDetails_ItemNumber]
    ON [AFISales_DW].[DimAdNoticeDetails]([Item Number]);


GO
CREATE STATISTICS [Stat_DimAdNoticeDetails_CustomerAccountNumber]
    ON [AFISales_DW].[DimAdNoticeDetails]([Customer Account Number]);


GO
CREATE STATISTICS [Stat_DimAdNoticeDetails_Key]
    ON [AFISales_DW].[DimAdNoticeDetails]([Key]);


GO
CREATE STATISTICS [Stat_DimAdNoticeDetails_AdDateEntered]
    ON [AFISales_DW].[DimAdNoticeDetails]([AD Date Entered]);


