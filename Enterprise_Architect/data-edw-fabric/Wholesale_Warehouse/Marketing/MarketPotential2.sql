CREATE TABLE [Marketing].[MarketPotential2]
    (
        [ID]                [CHAR](3)      NULL,
        [County]            [VARCHAR](50)  NULL,
        [StateAbbreviation] [CHAR](5)      NULL,
        [Year]              [INT]          NULL,
        [CEXCode]           VARCHAR(255)   NULL,
        [ProductLineCode]   CHAR(1)        NULL,
        [Amount]            DECIMAL(20, 2) NULL
    );