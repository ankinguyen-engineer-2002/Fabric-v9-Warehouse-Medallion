CREATE VIEW AFISales_DW_Wrk.v_DimADNoticeDetails
AS
    SELECT
            an.[Key],
            an.CustomerNumber         AS [Customer Account Number],
            CAST(' ' AS CHAR(4))      AS [Ship Number],
            ad.ItemSKU                AS [Item Number],
            an.UserLogin              AS [MS Name],
            an.RequestDate            AS [Delivery Date for AD],
            an.StartDate              AS [Start Date for AD],
            an.EndDate                AS [End Date for AD],
            an.Description            AS [AD Description],
            ad.Warehouse              AS [Warehouse],
            an.Comments               AS [AD Comments],
            CAST(an.DateAdded AS DATETIME) AS [AD Date Entered],
            an.SpecialDescription     AS [Special Discount Name and Code]
    FROM
            [$(Wholesale_Warehouse)].Marketing.AdNotice       an
        JOIN
            [$(Wholesale_Warehouse)].Marketing.AdNoticeDetail ad
                ON an.[Key] = ad.ForeignKey
