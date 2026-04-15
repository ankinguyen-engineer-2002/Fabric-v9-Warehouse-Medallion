CREATE SCHEMA [Quality_DW_Wrk]
    AUTHORIZATION [dbo];



GO
GRANT VIEW DEFINITION
    ON SCHEMA::[Quality_DW_Wrk] TO [Sg_AFI_Radar_PDW_RadarTeam_Unv];


GO
GRANT VIEW DEFINITION
    ON SCHEMA::[Quality_DW_Wrk] TO [SG_AFI_Radar_Finance_Unv];


GO
GRANT SELECT
    ON SCHEMA::[Quality_DW_Wrk] TO [Sg_AFI_Radar_PDW_RadarTeam_Unv];


GO
GRANT SELECT
    ON SCHEMA::[Quality_DW_Wrk] TO [SG_AFI_Radar_Finance_Unv];


GO
GRANT EXECUTE
    ON SCHEMA::[Quality_DW_Wrk] TO [Sg_AFI_Radar_PDW_RadarTeam_Unv];


GO
GRANT EXECUTE
    ON SCHEMA::[Quality_DW_Wrk] TO [SG_AFI_Radar_Finance_Unv];


