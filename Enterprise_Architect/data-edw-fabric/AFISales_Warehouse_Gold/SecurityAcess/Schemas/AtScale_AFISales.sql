CREATE SCHEMA [AtScale_AFISales]
    AUTHORIZATION [dbo];


GO
GRANT VIEW DEFINITION
    ON SCHEMA::[AtScale_AFISales] TO [Sg_AFI_RADAR_Finance_MS_Admin_Unv];



GO
GRANT SELECT
    ON SCHEMA::[AtScale_AFISales] TO [Sg_AFI_RADAR_Finance_MS_Admin_Unv];



GO
GRANT EXECUTE
    ON SCHEMA::[AtScale_AFISales] TO [Sg_AFI_RADAR_Finance_MS_Admin_Unv];

