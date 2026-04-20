CREATE TABLE [DW_Developer].[AuditLog]
    (
        [Description]  VARCHAR(200)  NULL,
        [DateTime]     DATETIME2(6)  NULL, --DATETIME
        [User]         VARCHAR(150)   NULL,
        [Command]      VARCHAR(8000) NULL
    );

GO

CREATE STATISTICS [Stat_AuditLog_Desc]
    ON [DW_Developer].[AuditLog]
    (
        [Description]
    );


GO
CREATE STATISTICS [Stat_AuditLog_DateTime]
    ON [DW_Developer].[AuditLog]
    (
        [DateTime]
    );


GO
CREATE STATISTICS [Stat_AuditLog_Command]
    ON [DW_Developer].[AuditLog]
    (
        [Command]
    );


GO
CREATE STATISTICS [Stat_AuditLog_User]
    ON [DW_Developer].[AuditLog]
    (
        [User]
    );
GO
