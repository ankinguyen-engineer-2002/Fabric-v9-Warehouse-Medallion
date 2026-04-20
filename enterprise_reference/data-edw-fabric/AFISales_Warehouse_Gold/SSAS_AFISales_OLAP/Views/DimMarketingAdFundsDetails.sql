CREATE VIEW [SSAS_AFISALES_OLAP].[DimMarketingAdFundsDetails]
AS
    SELECT
        [Ad Funds Key],
        [Ad Funds Modified Date],
        [Ad Funds Modified By],
        [Ad Funds Division],
        [Ad Funds Velocity Driver Name],
        [Ad Funds Type],
        [Ad Funds Approval Status],
        LEFT([Ad Funds Comments], 4000) AS [Ad Funds Comments],
        [Ad Funds Special Discount Code],
        [Ad Funds Event Name],
        [Ad Funds VP],
        [Ad Used For]
    FROM
        AFISales_DW.DimMarketingAdFundsDetails;