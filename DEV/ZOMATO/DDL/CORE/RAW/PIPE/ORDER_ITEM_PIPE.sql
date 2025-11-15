create or replace pipe ORDER_ITEM_PIPE auto_ingest=true integration='AZURE_QUEUE_INT' as COPY INTO RAW.ORDER_ITEM_RAW
FROM @RAW.ZOMATO_EXT_STAGE/order_item/
FILE_FORMAT = (FORMAT_NAME = RAW.FF_CSV_STD);
