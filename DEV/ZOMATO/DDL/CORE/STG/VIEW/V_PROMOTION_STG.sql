create or replace view V_PROMOTION_STG(
	PROMO_ID,
	PROMO_CODE,
	DISCOUNT_PERCENT,
	START_DATE,
	END_DATE,
	MAX_DISCOUNT_AMT,
	TARGET_SEGMENT,
	TARGET_CITY
) as
SELECT
  TRY_TO_NUMBER(PROMO_ID)                                     AS PROMO_ID,
  TRIM(PROMO_CODE)                                            AS PROMO_CODE,
  COALESCE(TRY_TO_NUMBER(DISCOUNT_PERCENT),0)                 AS DISCOUNT_PERCENT,
  TRY_TO_TIMESTAMP_NTZ(START_DATE)                            AS START_DATE,
  TRY_TO_TIMESTAMP_NTZ(END_DATE)                              AS END_DATE,
  COALESCE(TRY_TO_NUMBER(MAX_DISCOUNT_AMT),0)                 AS MAX_DISCOUNT_AMT,
  TRIM(TARGET_SEGMENT)                                        AS TARGET_SEGMENT,
  TRIM(TARGET_CITY)                                           AS TARGET_CITY
FROM RAW.PROMOTION_RAW;
