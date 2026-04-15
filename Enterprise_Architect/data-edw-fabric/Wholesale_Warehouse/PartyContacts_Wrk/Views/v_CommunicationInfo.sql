CREATE view [PartyContacts_Wrk].[v_CommunicationInfo]
as
SELECT [pcpLocationID]
      ,[pcpPartyId]
      ,[pcpContactType]
      ,[pcpContactId]
      ,[pcpSequenceNumber]
      ,[pcpDepartment]
      ,[pcpCommunicationValueExt] 
      ,[pcpCommunicationType]
      ,CAST([pcpCommunicationValue] AS VARCHAR(50)) AS [pcpCommunicationValue]
      ,[pcpIsDefault]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[pcpLastUserChanged]
      ,[pcpActiveEndDate]
  FROM [$(Source_Data)].[Wholesale_PartyContacts].[CommunicationInfo]



