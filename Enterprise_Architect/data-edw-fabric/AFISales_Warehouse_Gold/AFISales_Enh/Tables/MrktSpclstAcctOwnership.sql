CREATE TABLE [AFISales_Enh].[MrktSpclstAcctOwnership] (
    [Division]       CHAR (1)      NOT NULL,
    [Region]         CHAR (3)      NOT NULL,
    [RepID]          CHAR (5)      NOT NULL,
    [CustomerNumber] CHAR (8)      NOT NULL,
    [ShiptoNumber]   CHAR (4)      NOT NULL,
    [Ratio]          DECIMAL (8,4) NOT NULL
)

GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_ShiptoNumber]
    ON [AFISales_Enh].[MrktSpclstAcctOwnership]([ShiptoNumber]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_RepID]
    ON [AFISales_Enh].[MrktSpclstAcctOwnership]([RepID]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_Region]
    ON [AFISales_Enh].[MrktSpclstAcctOwnership]([Region]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_Division]
    ON [AFISales_Enh].[MrktSpclstAcctOwnership]([Division]);


GO
CREATE STATISTICS [Stat_MrktSpclstAcctOwnership_CustomerNumber]
    ON [AFISales_Enh].[MrktSpclstAcctOwnership]([CustomerNumber]);

