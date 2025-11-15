create or replace view V_RESTAURANT_STG(
	RESTAURANT_ID,
	RESTAURANT_NAME,
	CUISINE_PRIMARY,
	CUISINE_SECONDARY,
	CITY,
	AREA,
	LAT,
	LNG,
	AVG_RATING,
	COMMISSION_RATE,
	IS_ACTIVE,
	ONBOARDED_AT
) as
SELECT
  TRY_TO_NUMBER(RESTAURANT_ID)                                AS RESTAURANT_ID,
  TRIM(RESTAURANT_NAME)                                       AS RESTAURANT_NAME,
  TRIM(CUISINE_PRIMARY)                                       AS CUISINE_PRIMARY,
  TRIM(CUISINE_SECONDARY)                                     AS CUISINE_SECONDARY,
  NULLIF(TRIM(CITY),'')                                       AS CITY,
  NULLIF(TRIM(AREA),'')                                       AS AREA,
  TRY_TO_DOUBLE(LAT)                                          AS LAT,
  TRY_TO_DOUBLE(LNG)                                          AS LNG,
  COALESCE(TRY_TO_DOUBLE(AVG_RATING), 0.0)                    AS AVG_RATING,
  COALESCE(TRY_TO_DOUBLE(COMMISSION_RATE), 0.20)              AS COMMISSION_RATE,
  COALESCE(
    TRY_TO_BOOLEAN(
      CASE UPPER(TRIM(IS_ACTIVE))
        WHEN 'Y' THEN 'TRUE'
        WHEN '1' THEN 'TRUE'
        WHEN 'TRUE' THEN 'TRUE'
        ELSE 'FALSE'
      END
    ), FALSE
  )                                                           AS IS_ACTIVE,
  TRY_TO_TIMESTAMP_NTZ(ONBOARDED_AT)                          AS ONBOARDED_AT
FROM RAW.RESTAURANT_RAW;
