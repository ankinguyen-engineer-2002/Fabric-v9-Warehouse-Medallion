CREATE VIEW [PowerBI_Wholesale].[WeeklyPlacements]
AS
    SELECT
            WP.[Account And Shipto Number],
            WP.[Item SKU],
            WP.[Week Ended],
            WP.[Net Placement Gain],
            WP.[Weekly Quantity],
            WP.[Placement Gain],
            WP.[Placement Loss],
            WP.[Current Placements],
            WP.[At Risk Placements],
            WP.SalesTerritoryID
    FROM
            AFISales_DW.FactWeeklyPlacements WP
        --LEFT JOIN AFISales_DW.DimSalesTerritories ST  on WP.SalesTerritoryID=ST.SalesTerritoryID
        --Left Join AFISales_DW.DimCustomers C  on WP.[Account And Shipto Number] = C.[Account And Shipto Number]
        LEFT JOIN
            AFISales_DW.DimDateFile          D
                ON WP.[Week Ended] = D.[Transaction Date]
    WHERE
            D.[Fiscal Year] >= YEAR(GETDATE()) - 1;