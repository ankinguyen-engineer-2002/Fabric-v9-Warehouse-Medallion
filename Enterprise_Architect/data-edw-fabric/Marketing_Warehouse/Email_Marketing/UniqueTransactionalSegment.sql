CREATE TABLE [Email_Marketing].[UniqueTransactionalSegment]
(
        [Email_Date]     [DATETIME2](6) NULL,
        [Audience]       [VARCHAR](150) NULL,
        [MessageName]    [VARCHAR](250) NULL,
        [Email_MSG_TYP]  [VARCHAR](150) NULL,
        [Email_PROD_CAT] [VARCHAR](150) NULL,
        [Unique_Open]    [INT]          NULL,
        [Unique_Clicks]  [INT]          NULL
)
