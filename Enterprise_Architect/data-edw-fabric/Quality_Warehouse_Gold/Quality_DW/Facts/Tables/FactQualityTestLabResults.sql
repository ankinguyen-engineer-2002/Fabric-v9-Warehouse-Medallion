CREATE TABLE [Quality_DW].[FactQualityTestLabResults] (
    [RowID]                 BIGINT          NOT NULL,
    [Site]                  VARCHAR (30)    NOT NULL,
    [Location]              CHAR (3)        NOT NULL,
    [Vendor Number]         CHAR    (8)    NOT NULL,
    [Test Create Date]      DATE            NOT NULL,
    [Commodity SKU]         VARCHAR (15)    NOT NULL,
    [Commodity Category ID] INT             NOT NULL,
    [Sample Group ID]       INT             NOT NULL,
    [Sample ID]             INT             NOT NULL,
    [Test Definition ID]    INT             NOT NULL,
    [Question ID]           INT             NOT NULL,
    [Answer]                DECIMAL (10, 4) NULL,
    [Upper Limit]           DECIMAL (13, 4) NULL,
    [Nominal]               DECIMAL (13, 4) NULL,
    [Lower Limit]           DECIMAL (13, 4) NULL,
    [Part Primary Site ID]  CHAR (3)        NOT NULL
)



GO
CREATE STATISTICS [Stat_FactQualityTestLabResults_TestDefinitionID]
    ON [Quality_DW].[FactQualityTestLabResults]([Test Definition ID]);


GO
CREATE STATISTICS [Stat_FactQualityTestLabResults_TestCreateDate]
    ON [Quality_DW].[FactQualityTestLabResults]([Test Create Date]);


GO
CREATE STATISTICS [Stat_FactQualityTestLabResults_Site]
    ON [Quality_DW].[FactQualityTestLabResults]([Site]);


GO
CREATE STATISTICS [Stat_FactQualityTestLabResults_SampleID]
    ON [Quality_DW].[FactQualityTestLabResults]([Sample ID]);


GO
CREATE STATISTICS [Stat_FactQualityTestLabResults_QuestionID]
    ON [Quality_DW].[FactQualityTestLabResults]([Question ID]);


GO
CREATE STATISTICS [Stat_FactQualityTestLabResults_CommoditySKU]
    ON [Quality_DW].[FactQualityTestLabResults]([Commodity SKU]);

