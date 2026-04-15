CREATE VIEW [SSAS_AFISALES_OLAP].[FactAdnoticeData]
AS
    SELECT
            AD.[key] as andKey,
            AD.[Customer Account Number],
            AD.[Ship Number],
            AD.Territory,
            AD.[Delivery Date for AD],
            AD.[Start Date for AD],
            AD.[End Date for AD],
            AD.Warehouse,
            AD.[AD Date Entered],
            AD.SalesTerritoryID,
            AD.[Item Number],
            AD.[AD Goal Quantity],
            AD.[Ad Actual Qty],
            AD.[Notice Time Lead],
            AD.[Promotion Duration],
            AD.[Division Code],
            AD.[Customer Shipto Division Number],
            ST.RegionCode_RepID_Category
    FROM
            AFISales_DW.FactAdNoticeData    AD
        LEFT JOIN
            AFISales_DW.DimSalesTerritories ST
                ON ST.SalesTerritoryID = AD.SalesTerritoryID;