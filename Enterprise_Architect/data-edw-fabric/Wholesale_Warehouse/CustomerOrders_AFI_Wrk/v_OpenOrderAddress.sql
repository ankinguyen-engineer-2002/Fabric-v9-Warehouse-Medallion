CREATE VIEW [CustomerOrders_AFI_Wrk].[v_OpenOrderAddress]
 AS
    SELECT 
       ORDNO AS OrderNumber,    
       SHPNM AS ShiptoName,    
       SHIP1 AS ShiptoAddress1, 
       SHIP2 AS ShiptoAddress2,
       SHIP3 AS ShiptoAddress3,
       SHPST AS ShiptoState,    
       SHPZP AS ShiptoZipCode  
        
        
        FROM [$(Source_Data)].[Wholesale_Codis_AFI].[CODATAH]