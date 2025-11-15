create or replace view V_CUSTOMER_STG(
	CUSTOMER_ID,
	CUSTOMER_NAME,
	EMAIL,
	PRIMARY_PHONE,
	REGISTERED_AT,
	CITY,
	AREA,
	LAT,
	LNG,
	SEGMENT,
	IS_PRIME_MEMBER,
	STATUS
) as
SELECT
  TRY_TO_NUMBER(CUSTOMER_ID)                                  AS CUSTOMER_ID,
  TRIM(CUSTOMER_NAME)                                         AS CUSTOMER_NAME,
  LOWER(TRIM(EMAIL))                                          AS EMAIL,
  REGEXP_REPLACE(PRIMARY_PHONE, '[^0-9]', '')                 AS PRIMARY_PHONE,
  TRY_TO_TIMESTAMP_NTZ(REGISTERED_AT)                         AS REGISTERED_AT,
  NULLIF(TRIM(CITY), '')                                      AS CITY,
  NULLIF(TRIM(AREA), '')                                      AS AREA,
  TRY_TO_DOUBLE(LAT)                                          AS LAT,
  TRY_TO_DOUBLE(LNG)                                          AS LNG,
  COALESCE(NULLIF(TRIM(SEGMENT),''), 'New')                   AS SEGMENT,
  COALESCE(
    TRY_TO_BOOLEAN(
      CASE UPPER(TRIM(IS_PRIME_MEMBER))
        WHEN 'Y' THEN 'TRUE'
        WHEN '1' THEN 'TRUE'
        WHEN 'TRUE' THEN 'TRUE'
        ELSE 'FALSE'
      END
    ), FALSE
  )                                                           AS IS_PRIME_MEMBER,
  COALESCE(NULLIF(TRIM(STATUS),''), 'ACTIVE')                 AS STATUS
FROM RAW.CUSTOMER_RAW;
