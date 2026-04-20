CREATE TABLE [Retail_DW_Core].[Leadsv2] (
    [LocationId]      VARCHAR (50)  NULL,
    [SalesPersonID]   VARCHAR (50)  NULL,
    [LeadName]        VARCHAR (255) NULL,
    [email]           VARCHAR (255) NULL,
    [CustomerId]      VARCHAR (50)  NULL,
    [PhoneNumber]     VARCHAR (20)  NULL,
    [RelationshipId]  VARCHAR (50)  NULL,
    [ActivityDate]    DATE          NULL,
    [LastActivity]    DATE          NULL,
    [StorisAppUserId] VARCHAR (50)  NULL,
    [CartId]          VARCHAR (50)  NULL,
    [rel_created]     DATETIME2 (6) NULL,
    [staffIds]        VARCHAR (500) NULL
);
GO

