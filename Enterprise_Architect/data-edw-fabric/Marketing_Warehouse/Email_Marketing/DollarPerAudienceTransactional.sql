CREATE TABLE [Email_Marketing].[DollarPerAudienceTransactional]
    (
        [Email_Date]     [DATETIME2](6) NULL,
        [Audience]       [VARCHAR](150) NULL,
        [Email_PROD_CAT] [VARCHAR](150) NULL,
        [Messagename]    [VARCHAR](250) NULL,
        [Unique_Emails]  [INT]          NULL,
        [Revenue]        [FLOAT]        NULL
    );
