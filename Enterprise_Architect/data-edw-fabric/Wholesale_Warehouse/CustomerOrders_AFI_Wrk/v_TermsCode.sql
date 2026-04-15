
create VIEW [CustomerOrders_AFI_Wrk].v_TermsCode
AS
    SELECT
    [STDCOD],
    [STMDS],
    [STDAYS],
    [STCDUE],
    [STDDUE],
    [STSDES],
    [STPRTP],
    [STDMSG],
    [STDISP],
    [STDISD],
    [STMPCD] 
    FROM
           [$(Source_Data)].[Wholesale_Codis_AFI].[STDTRM]
     
	 