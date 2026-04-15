CREATE VIEW [CustomerOrders_AFI_Wrk].v_OpenOrderComments
AS
    SELECT
        [ORDNO],
        [CMTSQ],
        [OCMT1],
        [OCMT2],
        [OCMT3],
        [OINTP]
    FROM
        [$(Source_Data)].[Wholesale_Codis_AFI].[CODATAK]