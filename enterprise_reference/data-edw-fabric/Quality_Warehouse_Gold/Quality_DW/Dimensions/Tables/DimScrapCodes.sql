CREATE TABLE [Quality_DW].[DimScrapCodes]
    (
        [RowNumber]                           BIGINT       NOT NULL, --IDENTITY (1, 1)
        [Scrap Code]                          CHAR(4)      NOT NULL,
        [Defect Code]                         CHAR(2)      NOT NULL,
        [Defect Description]                  VARCHAR(25)  NOT NULL,
        [Defect Category]                     VARCHAR(20)  NOT NULL,
        [Location Code]                       CHAR(2)      NOT NULL,
        [Location Description]                VARCHAR(20)  NULL,
        [Scrap Code with CS Control Code]     CHAR(5)      NULL,
        [Customer Service Defect Code]        CHAR(3)      NULL,
        [Customer Service Defect Description] VARCHAR(100) NULL
    );

GO
CREATE STATISTICS [Stat_DimScrapCodes_Scrap_Code]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Scrap Code]
    );


GO
CREATE STATISTICS [Stat_DimScrapCodes_Defect_Code]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Defect Code]
    );


GO
CREATE STATISTICS [Stat_DimScrapCodes_Scrap_Code_with_CS_Control_Code]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Scrap Code with CS Control Code]
    );


GO
CREATE STATISTICS [Stat_DimScrapCodes_Location_Description]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Location Description]
    );


GO
CREATE STATISTICS [Stat_DimScrapCodes_Location_Code]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Location Code]
    );


GO
CREATE STATISTICS [Stat_DimScrapCodes_Defect_Description]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Defect Description]
    );


GO
CREATE STATISTICS [Stat_DimScrapCodes_Defect_Category]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Defect Category]
    );


GO
CREATE STATISTICS [Stat_DimScrapCodes_Customer_Service_Defect_Description]
    ON [Quality_DW].[DimScrapCodes]
    (
        [Customer Service Defect Description]
    );

