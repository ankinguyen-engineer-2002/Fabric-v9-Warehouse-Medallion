CREATE TABLE [PowerBI_Retail].[PeopleRecord] (
    [Operation]      VARCHAR (50) NULL,
    [PeopleID]       VARCHAR (20) NULL,
    [EmployeeNumber] VARCHAR (50) NOT NULL,
    [Email]          VARCHAR (50) NULL,
    [HireDate]       DATE         NULL,
    [JobID]          INT          NULL,
    [PeopleType_ID]  INT          NOT NULL,
    [ActiveStatus]   BIT          NULL,
    [CreatedDate]    DATE         NULL,
    [SupID]          VARCHAR (50) NULL,
    [FirstName]      VARCHAR (50) NULL,
    [LastName]       VARCHAR (50) NULL,
    [EmpStatus]      VARCHAR (5)  NULL,
    [EmpFTPT]        VARCHAR (5)  NULL,
    [LocationID]     VARCHAR (50) NULL,
    [DivisionID]     INT          NULL,
    [DepartmentID]   INT          NULL,
    [RegionID]       INT          NULL,
    [EmployeeTypeID] INT          NULL,
    [SepDate]        DATE         NULL
);
GO

