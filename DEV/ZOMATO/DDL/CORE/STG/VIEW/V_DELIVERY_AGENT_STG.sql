create or replace view V_DELIVERY_AGENT_STG(
	AGENT_ID,
	AGENT_NAME,
	PHONE,
	HIRE_DATE,
	CITY,
	VEHICLE_TYPE,
	STATUS
) as
SELECT
  TRY_TO_NUMBER(AGENT_ID)                                     AS AGENT_ID,
  TRIM(AGENT_NAME)                                            AS AGENT_NAME,
  REGEXP_REPLACE(PHONE, '[^0-9]', '')                         AS PHONE,
  TRY_TO_TIMESTAMP_NTZ(HIRE_DATE)                             AS HIRE_DATE,
  NULLIF(TRIM(CITY),'')                                       AS CITY,
  TRIM(VEHICLE_TYPE)                                          AS VEHICLE_TYPE,
  COALESCE(NULLIF(TRIM(STATUS),''),'ACTIVE')                  AS STATUS
FROM RAW.DELIVERY_AGENT_RAW;
