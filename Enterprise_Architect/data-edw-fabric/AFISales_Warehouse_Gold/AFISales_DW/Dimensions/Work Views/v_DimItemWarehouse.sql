
CREATE VIEW AFISales_DW_Wrk.v_DimItemWarehouse
AS
SELECT SCPFBRT.[Scp_Seq_Nbr] AS [Sequence Number],
       DimItemMaster.[ItemSKU] AS [AFI Item Number],
       LogResultantForecast.[rfcWarehouse] AS [AFI Warehouse],
       [Drp_Plnr_Id] AS [DRP Planner ID],
       CAST(CONCAT([Fcst_1_Id], '	', [Fcst_2_Id], '	', [Fcst_3_Id]) AS VARCHAR(36)) AS [Forecast ID],
       [Lvl_Nbr] AS [Forecast Level Number],
       [Abc_3_Code] AS [Alternate ABC-3 Code],
       [Abc_Ip_Code] AS [IP ABC Code],
       [Fcst_Plnr_Id] AS [Forecast Planner ID],
       CAST([Usr_01_Text] AS CHAR(2)) AS [Field 1],
       [Usr_07_Text] AS [Product Type],
       [Usr_20_Text] AS [Field 17],
       CAST(CASE
                WHEN [Usr_22_Text] = 'L' THEN
                    'L'
                ELSE
                    ''
            END AS CHAR(1)) AS [Product Watch Code],
       [Usr_25_Text] AS [Part Flag],
       [Prod_Grp_Id] AS [Product Group ID],
       [Fcst_Type_Code] AS [Forecast Type Code],
       [Dmd_Actl_Vld_Nbr] AS [Valid Demand],
       [Std_Dev_Sys_Frc_Qty] AS [Forced Sys Std Deviation],
       [Perm_Compt_Qty] AS [Perminent Component Quantity],
       [Uprc_Value] AS [Unit Price],
       [Drvd_Fcst_Fctr] AS [Derived Forecast Factor],
       CAST([Drvd_Item_Id] AS VARCHAR(36)) AS [Derived Forecast Key],
       [Drvd_Fcst_Lvl_Nbr] AS [Derived Forecast Level Number],
       [UCost_Value] AS [Unit Cost],
       [Unit_Cube_Ft_Qty] AS [Cubic Feet],
       [Trend_Compt_Qty] AS [Trend Component Quantity],
       [Dmd_Mgmt_Vld_Nbr] AS [Mgnmt Valid Demand],
       CAST([abc_primry_code] AS CHAR(1)) AS [ABC Primary Code],
       [Usr_09_Text] AS [Vendor Name]
FROM [$(Databricks)].wholesale_demandplanning_afi.scp_fcst_root SCPFBRT
    JOIN [$(Databricks)].[wholesale_demandplanning_afi].[logresultantforecast] LogResultantForecast
        ON [rfcScpSeqNbr] = [Scp_Seq_Nbr]
    JOIN [$(Databricks)].wholesale_demandplanning_afi.scpiprt SCPIPRT
        ON SCPFBRT.Scp_Seq_Nbr = SCPIPRT.Scp_Seq_Nbr
    JOIN [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
        ON DimItemMaster.ItemSKU = LogResultantForecast.[rfcItemNum]
WHERE SCPFBRT.[Lvl_Nbr] = 2
UNION ALL 
SELECT NULL AS [Sequence Number],
       [ItemSKU] AS [AFI Item Number],
       [Warehouse Code] AS [AFI Warehouse],
       --[Warehouse Code] AS [ItemWarehouse],
       NULL AS [DRP Planner ID],
       NULL AS [Forecast ID],
       NULL AS [Forecast Level Number],
       NULL AS [Alternate ABC-3 Code],
       NULL AS [IP ABC Code],
       NULL AS [Forecast Planner ID],
       NULL AS [Field 1],
       NULL AS [Product Type],
       NULL AS [Field 17],
       NULL AS [Product Watch Code],
       NULL AS [Part Flag],
       NULL AS [Product Group ID],
       NULL AS [Forecast Type Code],
       NULL AS [Valid Demand],
       NULL AS [Forced Sys Std Deviation],
       NULL AS [Perminent Component Quantity],
       NULL AS [Unit Price],
       NULL AS [Derived Forecast Factor],
       NULL AS [Derived Forecast Key],
       NULL AS [Derived Forecast Level Number],
       NULL AS [Unit Cost],
       NULL AS [Cubic Feet],
       NULL AS [Trend Component Quantity],
       NULL AS [Mgnmt Valid Demand],
       NULL AS [ABC Primary Code],
       NULL AS [Vendor Name]
FROM [$(MasterData_Warehouse)].MasterData_DW.DimItemMaster
    CROSS JOIN AFISales_DW.DimWarehouseMaster
    LEFT JOIN AFISales_DW.DimItemWarehouse
        ON ItemSKU = [AFI Item Number]
           AND [AFI Warehouse] = [Warehouse Code]
WHERE [AFI Item Number] IS NULL;
