-- Auto Generated (Do not modify) D7EC2E1CBF71575D21AF53592ADBA1C617468A4987EDD098B5B44BC6403FE7C2
CREATE     VIEW [Retail_DW_Core_Wrk].[v_FinanceSalesAttributionSends] AS

SELECT
   
    CONCAT(
        FORMAT(EventDateTime, 'yyyyMMddHHmmssfff'), '_',
        EmailAddress, '_',
        LEFT(EmailName, 50)
    ) AS SendID,

    CAST(EventDate AS DATE) AS EventDate,
    EventDateTime,
    EmailName,
    EmailAddress,
    CreationDate,
    Store
FROM  [$(Source_Data)].[Retail_Dart].[FinanceSalesAtributionSends];