create or replace pipe PAYMENT_PIPE auto_ingest=true integration='AZURE_QUEUE_INT' as COPY INTO RAW.PAYMENT_RAW
FROM @RAW.ZOMATO_EXT_STAGE/payment/
FILE_FORMAT = (FORMAT_NAME = RAW.FF_CSV_STD);
