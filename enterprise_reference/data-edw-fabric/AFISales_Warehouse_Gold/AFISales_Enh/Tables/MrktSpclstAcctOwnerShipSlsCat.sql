CREATE TABLE [AFISales_Enh].[MrktSpclstAcctOwnershipSlsCat] (
    [Division]       CHAR (1)      NOT NULL,
    [Region]         CHAR (3)      NOT NULL,
    [RepID]          CHAR (5)      NOT NULL,
    [CustomerNumber] CHAR (8)      NOT NULL,
    [ShiptoNumber]   CHAR (4)      NOT NULL,
    [SalesCategory]  CHAR (3)      NOT NULL,
    [Ratio]          DECIMAL (8,4) NOT NULL
)

GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_ShiptoNumber]
    ON [AFISales_Enh].[MrktSpclstAcctOwnershipSlsCat]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_SalesCategory]
    ON [AFISales_Enh].[MrktSpclstAcctOwnershipSlsCat]([SalesCategory]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_RepID]
    ON [AFISales_Enh].[MrktSpclstAcctOwnershipSlsCat]([RepID]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_Region]
    ON [AFISales_Enh].[MrktSpclstAcctOwnershipSlsCat]([Region]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_Division]
    ON [AFISales_Enh].[MrktSpclstAcctOwnershipSlsCat]([Division]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnershipSlsCat_CustomerNumber]
    ON [AFISales_Enh].[MrktSpclstAcctOwnershipSlsCat]([CustomerNumber]);


GO


