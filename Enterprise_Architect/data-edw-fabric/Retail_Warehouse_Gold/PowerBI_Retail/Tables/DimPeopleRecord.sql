CREATE TABLE [PowerBI_Retail].[DimPeopleRecord] (
    [JobID]           INT           NULL,
    [JobName]         VARCHAR (200) NULL,
    [SalesPersonName] VARCHAR (255) NULL,
    [PeopleID]        VARCHAR (20)  NULL,
    [SalesPersonID]   VARCHAR (30)  NOT NULL,
    [ActiveStatus]    VARCHAR (20)  NULL
);
GO

