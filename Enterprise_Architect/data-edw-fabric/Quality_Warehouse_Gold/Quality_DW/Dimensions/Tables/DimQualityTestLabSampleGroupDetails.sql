CREATE TABLE [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [RowNumber]             BIGINT        NOT NULL, --IDENTITY (1, 1) 
        [Commodity SKU]         VARCHAR(15)   NOT NULL,
        [Commodity Category ID] INT           NOT NULL,
        [Commodity Category]    VARCHAR(50)   NULL,
        [Sample Group ID]       INT           NOT NULL,
        [Sample ID]             INT           NOT NULL,
        [Test Definition ID]    INT           NOT NULL,
        [Test Name]             VARCHAR(50)   NULL,
        [Question ID]           INT           NOT NULL,
        [Question]              VARCHAR(35)   NOT NULL,
        [PO Number]             VARCHAR(30)   NOT NULL,
        [Test Date]             VARCHAR(30)   NOT NULL,
        [Remark]                VARCHAR(1000) NULL
    );

GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_TestDefinitionID]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Test Definition ID]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_SampleID]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Sample ID]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_QuestionID]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Question ID]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_Commodity_SKU]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Commodity SKU]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_Test_Name]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Test Name]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_Test_Date]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Test Date]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_Remark]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Remark]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_Question_ID]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Question ID]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_PO_Number]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [PO Number]
    );


GO
CREATE STATISTICS [Stat_DimQualityTestLabSampleGroupDetails_Commodity_Category]
    ON [Quality_DW].[DimQualityTestLabSampleGroupDetails]
    (
        [Commodity Category]
    );

