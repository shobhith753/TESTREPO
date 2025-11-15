-- Auto-generated STAGE DDL for ZOMATO_DWH.RAW.ZOMATO_EXT_STAGE
-- Generated at: 2025-11-15 19:47:48 UTC

CREATE OR REPLACE STAGE "ZOMATO_EXT_STAGE"
  URL = 'azure://snowflake2azuredemo1.blob.core.windows.net/zomato-landing/'
  STORAGE_INTEGRATION = AZURE_BLOB_INT;
