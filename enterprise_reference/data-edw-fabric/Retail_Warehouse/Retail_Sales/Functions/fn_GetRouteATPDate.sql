CREATE FUNCTION [Retail_Sales].[fn_GetRouteATPDate]
(
    @RouteCodeID VARCHAR(50),
    @TransDate DATE,
    @Pieces INT
)
RETURNS DATE
AS

    BEGIN

        DECLARE @RouteDate DATE; 

        SELECT
			@RouteDate = MIN(RouteDate)
        FROM [$(Databricks)].[retail_corporate].[routedetail] rd
        WHERE rd.RouteDate >= @TransDate
        AND rd.RouteCodeID = @RouteCodeID
        AND ((rd.MaxPieces - rd.ActualPieces >= @Pieces OR rd.MaxPieces IS NULL)
        AND (rd.MaxCubes - rd.ActualCubes > 0 OR rd.MaxCubes IS NULL)
        AND (rd.MaxStops - rd.ActualStops > 0 OR rd.MaxStops IS NULL)
        AND (rd.MaxValue - rd.ActualValue > 0 OR rd.MaxValue IS NULL));

        RETURN @RouteDate;

    END