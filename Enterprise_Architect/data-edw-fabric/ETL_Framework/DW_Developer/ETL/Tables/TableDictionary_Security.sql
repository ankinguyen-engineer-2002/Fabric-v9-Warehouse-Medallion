CREATE TABLE [DW_Developer].[TableDictionary_Security]
    (
        [UserName]            VARCHAR(100) NOT NULL,
        [DatabaseName]        VARCHAR(100) NOT NULL,
        [SchemaMapping]       VARCHAR(100) NOT NULL,
        [Select]              BIT          NOT NULL,
        [Execute]             BIT          NOT NULL,
        [ViewDefinition]      BIT          NOT NULL,
        [Insert]              BIT          NOT NULL,
        [Delete]              BIT          NOT NULL,
        [Update]              BIT          NOT NULL,
        [Alter]               BIT          NOT NULL,
        [Control]             BIT          NOT NULL,
        [References]          BIT          NOT NULL,
        [Include_WRK_Schemas] BIT          NOT NULL,
        [Include_XBK_Schemas] BIT          NOT NULL,
        [Unmask]              BIT          NOT NULL
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_SchemaMapping]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [SchemaMapping]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_ViewDefinition]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [ViewDefinition]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Update]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Update]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Select]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Select]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_References]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [References]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Insert]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Insert]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Include_XBK_Schemas]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Include_XBK_Schemas]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Include_WRK_Schemas]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Include_WRK_Schemas]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Execute]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Execute]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Delete]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Delete]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Control]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Control]
    );


GO
CREATE STATISTICS [Stat_TableDictionary_Security_Alter]
    ON [DW_Developer].[TableDictionary_Security]
    (
        [Alter]
    );

