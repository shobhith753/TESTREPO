create or replace view V_CUSTOMER_FEEDBACK_STG(
	FEEDBACK_ID,
	ORDER_ID,
	CUSTOMER_ID,
	RATING,
	COMMENT,
	SENTIMENT_SCORE,
	CREATED_AT
) as
SELECT
  TRY_TO_NUMBER(FEEDBACK_ID)                                 AS FEEDBACK_ID,
  TRY_TO_NUMBER(ORDER_ID)                                    AS ORDER_ID,
  TRY_TO_NUMBER(CUSTOMER_ID)                                 AS CUSTOMER_ID,
  COALESCE(TRY_TO_NUMBER(RATING),0)                          AS RATING,
  COMMENT                                                    AS COMMENT,
  TRY_TO_DOUBLE(SENTIMENT_SCORE)                             AS SENTIMENT_SCORE,
  TRY_TO_TIMESTAMP_NTZ(CREATED_AT)                           AS CREATED_AT
FROM RAW.CUSTOMER_FEEDBACK_RAW;
