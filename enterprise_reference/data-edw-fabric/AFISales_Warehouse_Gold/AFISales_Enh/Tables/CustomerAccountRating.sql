CREATE TABLE [AFISales_Enh].[CustomerAccountRating] (
    [CustomerNumber]         CHAR (13)    NOT NULL,
    [CurrentYearRating]      CHAR (1)     NULL,
    [PreviousYearRating]     CHAR (1)     NULL,
    [SecondYearRating]       CHAR (1)     NULL,
    [Account Exception Flag] BIT          NOT NULL
)


GO
CREATE STATISTICS [Stat_CustomerAccountRating_SecondYearRating]
    ON [AFISales_Enh].[CustomerAccountRating]([SecondYearRating]);


GO
CREATE STATISTICS [Stat_CustomerAccountRating_PreviousYearRating]
    ON [AFISales_Enh].[CustomerAccountRating]([PreviousYearRating]);


GO
CREATE STATISTICS [Stat_CustomerAccountRating_CurrentYearRating]
    ON [AFISales_Enh].[CustomerAccountRating]([CurrentYearRating]);


GO
CREATE STATISTICS [Stat_CustomerAccountRating_Account_Exception_Flag]
    ON [AFISales_Enh].[CustomerAccountRating]([Account Exception Flag]);

