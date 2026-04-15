create view PartyContacts_Wrk.v_Locations
as
SELECT  [pltLocationID]
      ,[pltPartyID]
      ,[pltAddressID]
      ,[pltDescription]
      ,[pltLocationType]
      ,[pltAddressVerificationDate]
    --  ,[pltReverificationFrequency]
      ,[pltOutsideSourceType]
      ,[pltOutsideSourceLocation]
      ,[usra]
      ,[dtea]
      ,[usrc]
      ,[dtec]
      ,[pltActiveEndDate]
      ,[pltShortDescription]
  FROM [$(Source_Data)].[Wholesale_PartyContacts].[Locations]
GO

