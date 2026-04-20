-- Auto Generated (Do not modify) FB035B16AA49BD6B17A65FBF621F882DF761F1076FF824BBBAABD3C196F9D26E
CREATE   VIEW [Retail_DW_NonCore_Wrk].[V_DMDespIsedInvActivity] AS
SELECT 
    TransID,
    ActivityTypeID,
    Description,
    StoreBrandID,
    LocationID,
    ProductID,
    ReClassIn,
    ReClassOut,
    ReasonCodeID,
    TotalCost,
    Starting,
    Created,
    Adjust,
    Transfer,
    Sold,
    SerialNo,
    InvSubBucketID,
    RefSubBucketID,
    TransDate,
    PeriodDate,
    TransQty
FROM [$(Source_Data)].[Retail_Dart].[DMDespIsedInvActivity];