CREATE TABLE [AFISales_Enh].[Ecommerce_ShippingRates] (
    [ItemNumber]        VARCHAR (15)   NULL,
    [ItemType]          VARCHAR (10)   NULL,
    [CarrierZone]       INT            NULL,
    [UPSShippingrate]   DECIMAL (10,2) NULL,
    [FedexShippingrate] DECIMAL (10,2) NULL,
    [ZoneSuggestion]    VARCHAR (100)  NULL
)


Go 

CREATE STATISTICS Stat_Ecommerce_ShippingRates_ItemNumber 
    ON AFISales_Enh.Ecommerce_ShippingRates  ([ItemNumber]);
GO
CREATE STATISTICS Stat_Ecommerce_ShippingRates_CarrierZone 
    ON AFISales_Enh.Ecommerce_ShippingRates ([CarrierZone]);
GO
