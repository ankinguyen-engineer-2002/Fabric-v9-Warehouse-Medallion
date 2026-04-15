-- Auto Generated (Do not modify) 6CA44F6EB32B4A6BBBCB7486CFF99AC02D1E501A16EF3D7499ED22A14B75AE6F
CREATE   VIEW [Retail_DW_Core_Wrk].[v_Epsilon_Bounces] AS

SELECT 
    [StoreBrandID],
    [Audience],
    [ServiceTransactionID],
    [ServiceCommunicationID],
    [JobID],
    [BounceSubcategory],
    [BounceTypeID],
    [BounceType],
    [SMTPCode],
    [TriggererSendDefinitionObjectID],
    [TriggeredSendCustomerKey],
    [SubscriberKey],
    [EventDate],
    [Domain],
    [BounceCategoryID],
    [BounceCategory],
    [BounceSubcategoryID],
    [OrgID],
    [DeploymentID],
    [MessageID],
    [CustomerKey] 
FROM [$(Source_Data)].[Retail_Dart].[Epsilon_Bounces]
WHERE MessageID IN ( 'e55bb9d4-1e05-4d7d-8993-731b9134661a', '99c0959a-4eb3-419c-a879-c9f57179d811',
                     'ef695344-9fda-4c94-9cde-d86f841aaf0e', 'dc47a9cb-a96e-4c0a-a798-1c912e8da734',
                     '6bdd3417-76c3-4928-842c-fdf949ebe898', 'ba0f594e-4268-4440-8a0a-3c6aef556283',
                     '8e07b800-f0ee-4ad2-84db-b948e5050857', 'b4c07418-396a-4d1d-a06b-e2382a68a23e',
                     'aa1a99fa-378b-4b33-abf4-bafb1d3e4ac8', '1c74724b-6a8a-499a-a79d-61aa2da736e7',
                     '005fdb8c-12fc-4c8a-b81b-23894a7bf526', '9ef7840d-d555-4123-abd3-c7c57b8981ed'
                   )