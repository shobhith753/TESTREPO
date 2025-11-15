create or replace pipe MENU_ITEM_PIPE auto_ingest=true integration='AZURE_QUEUE_INT' as COPY INTO RAW.MENU_ITEM_RAW
FROM @RAW.ZOMATO_EXT_STAGE/menu_item/
FILE_FORMAT = (FORMAT_NAME = RAW.FF_CSV_STD);
