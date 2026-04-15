CREATE FUNCTION [Retail_OOM_Wrk].[sfn_PieceInvSubBucketID]
(
    @ProductStatus VARCHAR(10),
    @TransCodeID INT,
    @ReasonCodeID VARCHAR(10),
    @SoftCommitted INT,
    @InventoryTierID VARCHAR(10),
    @StorageID VARCHAR(10),
    @PurchaseStatusID VARCHAR(5)
)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @InvSubBucketID VARCHAR(10),
            @InvSubBucketCode VARCHAR(10);


    SET @InvSubBucketID = 'UN';

    IF @ReasonCodeID IS NOT NULL
        SELECT @InvSubBucketCode = InvSubBucketCode
        FROM tdg.ReasonCode
        WHERE ReasonCodeID = @ReasonCodeID;
    ELSE
        SET @InvSubBucketCode = NULL;

    IF @SoftCommitted = 1
    BEGIN
        IF (@TransCodeID IS NOT NULL)
            SET @InvSubBucketID = 'RIT';
        ELSE
            SET @InvSubBucketID = 'RSV';
    END;

    IF @InvSubBucketID = 'UN'
    BEGIN
        IF @StorageID = 'RESEARCH'
            SET @InvSubBucketID = 'NIL';

    END;

    IF @InvSubBucketID = 'UN'
    BEGIN
        IF (NOT @ReasonCodeID IS NULL)
        BEGIN
            IF (@InvSubBucketCode IS NULL)
                SET @InvSubBucketID = 'ONS';
            ELSE
            BEGIN
                IF @InvSubBucketCode <> '1'
                    SET @InvSubBucketID = @InvSubBucketCode;
            END;
        END;
    END;



    IF @InvSubBucketID = 'UN'
    BEGIN
        IF @PurchaseStatusID IN ( 'D', 'T' )
            SET @InvSubBucketID = 'MFR';
    END;


    IF @InvSubBucketID = 'UN'
    BEGIN

        IF @ProductStatus = 'SPBUY'
            SET @InvSubBucketID = 'SPB';
    END;


    IF @InvSubBucketID = 'UN'
    BEGIN
        IF @InventoryTierID = '1.5'
           OR @InventoryTierID = '2.0'
            SET @InvSubBucketID = 'BS';
        ELSE
            SET @InvSubBucketID = 'GS';
    END;

    RETURN @InvSubBucketID;
END;