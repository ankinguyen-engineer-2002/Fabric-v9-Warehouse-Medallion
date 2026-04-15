CREATE TABLE [Quality_DW].[DimReasonCodesAshcomm]
    (
        [Reason Type]        VARCHAR(100) NOT NULL,
        [Reason Code]        VARCHAR(50)  NOT NULL,
        [Reason Description] VARCHAR(100) NULL
    );


GO
CREATE STATISTICS [Stat_DimReasonCodesAshcomm_Reason_Description]
    ON [Quality_DW].[DimReasonCodesAshcomm]
    (
        [Reason Description]
    );


GO
CREATE STATISTICS [Stat_DimReasonCodesAshcomm_Reason_Code]
    ON [Quality_DW].[DimReasonCodesAshcomm]
    (
        [Reason Code]
    );

