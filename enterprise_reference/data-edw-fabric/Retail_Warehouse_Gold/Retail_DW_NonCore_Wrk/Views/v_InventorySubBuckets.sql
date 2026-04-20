-- Auto Generated (Do not modify) 655E2546AEE37341113B64C3DD00778CCA5CAA394A809EA20A7A83890A9DC7D2
CREATE   VIEW [Retail_DW_NonCore_Wrk].[v_InventorySubBuckets] AS
SELECT 
    InvSubBucketID,
    SubBucketName,
    SubBucketSort,
    InvBucketID,
    BucketName,
    BucketSort
FROM [$(Source_Data)].[Retail_External].[InventorySubBuckets];