-- Auto Generated (Do not modify) EB435B249038A2C365BFD79CB438C79F85A35C605008392CD804D1A08213F1AF
CREATE   VIEW [Retail_DW_Core_Wrk].[v_FinanceProvider] AS

SELECT 
    [Operation],
    [AccountRetentionDays],
    [Address1],
    [Address2],
    [AllowFinanceB4Approval],
    [AllowInQueue],
    [SettlementType],
    [SourceID],
    [State],
    [UseTaxCodeSettingForRTOTaxRemoval],
    [XmitBothExchangeTransations],
    [Phone],
    [PhoneExt],
    [PostalCodeID],
    [PostMethod],
    [ReadyForQueue],
    [RecStatus],
    [Fax],
    [FinanceProviderID],
    [LastBatchID],
    [Name],
    [NotifyFinanceProvider],
    [PaymentTypeID],
    [City],
    [Contact],
    [DateChanged],
    [DateCreated],
    [DefaultPercent],
    [DefaultTier]
FROM [$(Source_Data)].[Retail_Corporate].[FinanceProvider];