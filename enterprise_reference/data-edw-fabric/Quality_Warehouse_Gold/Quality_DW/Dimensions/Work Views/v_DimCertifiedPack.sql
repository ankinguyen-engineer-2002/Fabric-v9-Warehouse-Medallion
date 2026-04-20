CREATE VIEW [Quality_DW_Wrk].[v_DimCertifiedPack]
AS select t1.[ItemNo]
, t1.[SeriesNo]
, (case when exists (select 1
                          from [$(Databricks)].[masterdata_productknowledge].[itempackagecertification] As t2
                          where t2.[ipcItemNumber] = t1.[ItemNo]
                         )
             then 'Y' else 'N'
end) as Certifiedpack
from [Quality_DW].[FactCalculatedColumns] As t1