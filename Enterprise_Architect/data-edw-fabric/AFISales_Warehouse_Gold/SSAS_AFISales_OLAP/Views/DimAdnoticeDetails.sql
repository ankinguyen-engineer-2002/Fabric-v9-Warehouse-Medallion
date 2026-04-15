CREATE VIEW [SSAS_AFISALES_OLAP].[DimAdnoticeDetails]
AS
    SELECT
        [Key] as andkey,
        [Customer Account Number],
        [Ship Number],
        [Item Number],
        [MS Name],
        [Delivery Date for AD],
        [Start Date for AD],
        [End Date for AD],
        [AD Description],
        Warehouse,
        [AD Comments],
        [AD Date Entered],
        [Special Discount Name and Code]
    FROM
        AFISales_DW.DimAdNoticeDetails;