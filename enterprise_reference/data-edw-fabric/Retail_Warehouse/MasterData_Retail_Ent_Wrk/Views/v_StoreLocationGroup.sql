-- Auto Generated (Do not modify) 47E5F889978944728D28167C142AED6B84A59FE5C5B935F3124A37EBB9C3B3C1
CREATE VIEW [MasterData_Retail_Ent_Wrk].[v_StoreLocationGroup]
AS
SELECT
	LocationID AS StoreID
	, CASE WHEN LocationID IN ('005','006') AND LocationGroupID = 'NTENN' THEN 'NINLOU' 
	   WHEN LocationID = 326 AND LocationGroupID = 'WSWCA' THEN 'WCALC'
       WHEN LocationID = 333 AND LocationGroupID = 'WSWCA' THEN 'WCALN'
       WHEN LocationGroupID = 'WNECA' THEN 'WCALE'
       WHEN LocationGroupID = 'WNWCA' THEN 'WCALW'
       WHEN LocationGroupID = 'WSECA' THEN 'WCALC'
       WHEN LocationGroupID = 'WSNCA' THEN 'WCALN'
       WHEN LocationGroupID = 'WSWCA' THEN 'WCALS'
       WHEN LocationGroupID = 'WWSID' THEN 'WSEAI'
       ELSE LocationGroupID
	   END AS LocationGroupID
	, PrimaryLocationGroupID
FROM [$(Source_Data)].[Retail_External].[LocationGroups]
WHERE ISNUMERIC(LocationID) = 1 AND Active =1;