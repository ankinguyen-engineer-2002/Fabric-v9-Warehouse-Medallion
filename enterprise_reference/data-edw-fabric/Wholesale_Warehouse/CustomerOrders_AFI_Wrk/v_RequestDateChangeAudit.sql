CREATE VIEW CustomerOrders_AFI_Wrk.[v_RequestDateChangeAudit]
  AS
      SELECT  OrderNumber AS OrderNumber,
              CustomerNumber AS CUstomerNumber,
              ShipToNumber AS ShiptoNumber,
              OldRequestDate AS OldRequestDate,
              NewRequestDate AS NewRequestDate,
              Reason AS Reason,
              ChangeDate AS ChangeDate,
              ChangeItem AS ChangeItem,
              ChangeUser AS ChangeUser
        FROM 
             [$(Source_Data)].[Wholesale_SalesHistory_AFI].[RequestDateChangeAudit]