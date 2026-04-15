CREATE TABLE [CostAccounting_DW].[DimItemDetail] (
    [ItemDetailKey]                    BIGINT       NOT NULL,--IDENTITY
    [Item Number]                      VARCHAR (25) NOT NULL,
    [Quantity Unit of Measure]         CHAR    (2)  NOT NULL,
    [Item Class]                       CHAR    (4)  NOT NULL,
    [Item Class Description]           VARCHAR (25) NOT NULL,
    [Item Description]                 VARCHAR (30) NOT NULL,
    [Item Type]                        CHAR    (1)  NOT NULL,
    [Financial Division]               CHAR    (1)  NOT NULL,
    [Financial Division Description]   VARCHAR (30) NOT NULL,
    [Sales Division]                   CHAR    (1)  NOT NULL,
    [Sales Division Description]       VARCHAR (25) NOT NULL,
    [Freight Sales Class]              CHAR    (2)  NOT NULL,
    [Commission Sales Class]           CHAR    (2)  NOT NULL,
    [Series]                           VARCHAR (10) NOT NULL,
    [Discount Sales Class]             CHAR    (2)  NOT NULL,
    [Manufacturing Status Code]        CHAR    (1)  NOT NULL,
    [Manufacturing Status Description] VARCHAR (25) NOT NULL
);

